//
//  MockSessionStore.swift
//  AuthApp
//
//  Created by Alejo Barbosa on 29/07/26.
//

@testable import AuthApp

final class MockSessionStore: SessionStore, @unchecked Sendable {
    private(set) var savedToken: String?

    func seed(token: String) {
        savedToken = token
    }

    func save(token: String) throws {
        savedToken = token
    }

    func loadToken() throws -> String? {
        savedToken
    }

    func clear() throws {
        savedToken = nil
    }
}
