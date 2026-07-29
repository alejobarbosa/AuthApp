//
//  APIClientTests.swift
//  AuthApp
//
//  Created by Alejo Barbosa on 28/07/26.
//

import Testing
import Foundation
@testable import AuthApp

private struct FixtureResponse: Decodable, Equatable, Sendable {
    let accessToken: String
}

private struct FakeLoginEndpoint: Endpoint {
    var path: String { "/auth/login" }
    var method: HTTPMethod { .post }
    var requiresAuth: Bool { false }
}

private struct FakeProtectedEndpoint: Endpoint {
    var path: String { "/commissions" }
    var method: HTTPMethod { .get }
}

private struct FixedTokenInterceptor: AuthorizationInterceptor {
    let token: String?
    func currentToken() async -> String? { token }
}

/// Anchor type so `Bundle(for:)` can locate this test target's bundle (and
/// therefore its bundled fixture JSON). This is a plain Xcode test target,
/// not a Swift Package, so `Bundle.module` isn't available here.
private final class TestBundleAnchor {}

private struct FixtureNotFoundError: Error {}

@Suite("APIClient", .serialized)
struct APIClientTests {

    private func loadFixture(_ name: String) throws -> Data {
        let bundle = Bundle(for: TestBundleAnchor.self)
        guard let url = bundle.url(forResource: name, withExtension: "json") else {
            throw FixtureNotFoundError()
        }
        return try Data(contentsOf: url)
    }

    private func makeClient(
        statusCode: Int,
        fixtureName: String,
        requestURL: String = "https://site.api-test.devmds.com/auth/login",
        authorizationInterceptor: AuthorizationInterceptor = NoAuthorizationInterceptor()
    ) throws -> APIClient {
        let data = try loadFixture(fixtureName)
        let session = URLProtocolStub.makeStubbedSession()
        URLProtocolStub.stubResponseData = data
        URLProtocolStub.stubResponse = HTTPURLResponse(
            url: URL(string: requestURL)!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: ["Content-Type": "application/json"]
        )
        return APIClient(
            session: session,
            baseURL: URL(string: "https://site.api-test.devmds.com")!,
            authorizationInterceptor: authorizationInterceptor,
            retryPolicy: .noRetry
        )
    }

    @Test("Decodes a successful response")
    func successfulDecode() async throws {
        let client = try makeClient(statusCode: 200, fixtureName: "auth_success")
        let response: FixtureResponse = try await client.send(FakeLoginEndpoint())
        #expect(response.accessToken.hasPrefix("eyJ"))
    }

    @Test("Maps 401 to NetworkError.unauthorized")
    func unauthorizedMapping() async throws {
        let client = try makeClient(statusCode: 401, fixtureName: "auth_unauthorized")
        do {
            let _: FixtureResponse = try await client.send(FakeLoginEndpoint())
            Issue.record("Expected NetworkError.unauthorized, got success")
        } catch let error as NetworkError {
            #expect(error == .unauthorized)
        }
    }

    @Test("Maps an unexpected status to NetworkError.http")
    func httpErrorMapping() async throws {
        let client = try makeClient(statusCode: 500, fixtureName: "auth_unauthorized")
        do {
            let _: FixtureResponse = try await client.send(FakeLoginEndpoint())
            Issue.record("Expected NetworkError.http, got success")
        } catch let error as NetworkError {
            guard case .http(let status, _) = error else {
                Issue.record("Expected .http, got \(error)")
                return
            }
            #expect(status == 500)
        }
    }

    @Test("Malformed body maps to NetworkError.decoding, never crashes")
    func malformedBodyMapping() async throws {
        let client = try makeClient(statusCode: 200, fixtureName: "malformed")
        do {
            let _: FixtureResponse = try await client.send(FakeLoginEndpoint())
            Issue.record("Expected NetworkError.decoding, got success")
        } catch let error as NetworkError {
            guard case .decoding = error else {
                Issue.record("Expected .decoding, got \(error)")
                return
            }
        }
    }

    @Test("Fails fast with .unauthorized when auth is required but no token is available")
    func missingTokenFailsFast() async throws {
        let client = try makeClient(statusCode: 200, fixtureName: "auth_success")
        do {
            let _: FixtureResponse = try await client.send(FakeProtectedEndpoint())
            Issue.record("Expected .unauthorized, got success")
        } catch let error as NetworkError {
            #expect(error == .unauthorized)
        }
    }

    @Test("Attaches a well-formed Authorization header when a token is available")
    func attachesAuthorizationHeader() async throws {
        var capturedRequest: URLRequest?
        let client = try makeClient(
            statusCode: 200,
            fixtureName: "auth_success",
            requestURL: "https://site.api-test.devmds.com/commissions",
            authorizationInterceptor: FixedTokenInterceptor(token: "abc123")
        )
        URLProtocolStub.requestHandler = { capturedRequest = $0 }

        let _: FixtureResponse = try await client.send(FakeProtectedEndpoint())

        // Guards against the exact bug found while manually verifying the
        // Swagger contract: a token pasted with stray quotes produced
        // `Authorization: Bearer "eyJ..."`, which the API correctly rejected.
        #expect(capturedRequest?.value(forHTTPHeaderField: "Authorization") == "Bearer abc123")
    }
}
