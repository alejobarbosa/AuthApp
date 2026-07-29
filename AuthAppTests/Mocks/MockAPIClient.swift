//
//  MockAPIClient.swift
//  AuthApp
//
//  Created by Alejo Barbosa on 28/07/26.
//

@testable import AuthApp

/// `resultProvider` must be set before `send` is called. An unset provider
/// is a test-authoring mistake, not something a real caller could hit, so
/// it fails loudly instead of returning a silent default.
final class MockAPIClient: APIClientProtocol, @unchecked Sendable {
    private(set) var callCount = 0
    var resultProvider: (@Sendable () throws -> any Decodable & Sendable)?

    func send<E: Endpoint, Response: Decodable & Sendable>(_ endpoint: E) async throws -> Response {
        callCount += 1
        guard let resultProvider else {
            fatalError("MockAPIClient.resultProvider must be set before use")
        }
        let result = try resultProvider()
        guard let typed = result as? Response else {
            fatalError("MockAPIClient configured with \(type(of: result)) but caller expected \(Response.self)")
        }
        return typed
    }
}
