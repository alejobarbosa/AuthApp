//
//  APIClient.swift
//  AuthApp
//
//  Created by Alejo Barbosa on 28/07/26.
//

import Foundation

/// Minimal seam over `URLSession` so tests can substitute a stub transport
/// (`URLProtocolStub`) without mocking URLSession's much larger surface area.
protocol URLSessionProtocol: Sendable {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {}

/// Production implementation of `APIClientProtocol`.
///
/// Holds no mutable state — `baseURL` is fixed at construction and the
/// bearer token is fetched fresh on every call via `authorizationInterceptor`,
/// so a single `APIClient` instance is safe to share across concurrent
/// requests: it never caches a token that could go stale mid-session.
final class APIClient: APIClientProtocol {
    private let session: URLSessionProtocol
    private let baseURL: URL
    private let authorizationInterceptor: AuthorizationInterceptor
    private let retryPolicy: RetryPolicy
    private let logger: Logger

    /// - Parameters:
    ///   - session: transport to use. Defaults to `URLSession.shared` in
    ///     production; tests inject a session backed by `URLProtocolStub`.
    ///   - baseURL: the API's base URL.
    ///   - authorizationInterceptor: supplies the bearer token for endpoints
    ///     that require it. Defaults to `NoAuthorizationInterceptor` so an
    ///     `APIClient` used only for unauthenticated calls (e.g. login)
    ///     doesn't need a real session dependency at all.
    ///   - retryPolicy: retry behavior for transient transport failures.
    ///   - logger: redacted logging; never receives request bodies or
    ///     Authorization header values.
    init(
        session: URLSessionProtocol = URLSession.shared,
        baseURL: URL,
        authorizationInterceptor: AuthorizationInterceptor = NoAuthorizationInterceptor(),
        retryPolicy: RetryPolicy = .default,
        logger: Logger = Logger(category: "Networking")
    ) {
        self.session = session
        self.baseURL = baseURL
        self.authorizationInterceptor = authorizationInterceptor
        self.retryPolicy = retryPolicy
        self.logger = logger
    }

    func send<E: Endpoint, Response: Decodable & Sendable>(
        _ endpoint: E
    ) async throws -> Response {
        let token = endpoint.requiresAuth ? await authorizationInterceptor.currentToken() : nil
        let request = try HTTPRequestBuilder.build(endpoint: endpoint, baseURL: baseURL, bearerToken: token)
        return try await executeWithRetry(request, attempt: 1)
    }

    private func executeWithRetry<Response: Decodable & Sendable>(
        _ request: URLRequest,
        attempt: Int
    ) async throws -> Response {
        do {
            return try await execute(request)
        } catch let error where retryPolicy.shouldRetry(error, attempt: attempt) {
            logger.log(.info, "Retrying request (attempt \(attempt + 1))", sensitive: false)
            try await Task.sleep(for: retryPolicy.delay(forAttempt: attempt))
            return try await executeWithRetry(request, attempt: attempt + 1)
        }
    }

    private func execute<Response: Decodable & Sendable>(
        _ request: URLRequest
    ) async throws(NetworkError) -> Response {
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch let urlError as URLError {
            throw NetworkError.transport(urlError)
        } catch {
            throw NetworkError.unknown(description: String(describing: error))
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        try validate(status: httpResponse.statusCode, data: data)

        do {
            return try JSONDecoder.apiDecoder.decode(Response.self, from: data)
        } catch let decodingError as DecodingError {
            logger.log(.error, "Decoding failed for \(Response.self)", sensitive: false)
            throw NetworkError.decoding(decodingError)
        } catch {
            throw NetworkError.unknown(description: String(describing: error))
        }
    }

    private func validate(status: Int, data: Data) throws(NetworkError) {
        switch status {
        case 200...299:
            return
        case 401:
            throw NetworkError.unauthorized
        default:
            throw NetworkError.http(status: status, data: data)
        }
    }
}

extension JSONDecoder {
    /// Shared decoder configured for ISO 8601 dates (matches `createdAt` on
    /// the Commission resource, Day 3) and default key decoding — the API's
    /// JSON already uses camelCase, so no key-decoding strategy conversion
    /// is applied.
    static let apiDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
}

