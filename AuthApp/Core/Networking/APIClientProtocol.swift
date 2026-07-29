//
//  APIClientProtocol.swift
//  AuthApp
//
//  Created by Alejo Barbosa on 28/07/26.
//

public protocol APIClientProtocol: Sendable {
    /// Sends `endpoint` and decodes the response body as `Response`.
    ///
    /// Throws `NetworkError` for every failure category (transport, HTTP,
    /// decoding, authorization) — never a raw, unclassified `Error`.
    func send<E: Endpoint, Response: Decodable & Sendable>(_ endpoint: E) async throws -> Response
}

