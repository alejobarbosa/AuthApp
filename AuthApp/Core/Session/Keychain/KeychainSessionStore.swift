//
//  KeychainSessionStore.swift
//  AuthApp
//
//  Created by Alejo Barbosa on 29/07/26.
//

import Foundation

final class KeychainSessionStore: SessionStore {
    private let keychain: KeychainWrapper
    private let tokenKey = "session.accessToken"

    init(keychain: KeychainWrapper = KeychainWrapper()) {
        self.keychain = keychain
    }

    func save(token: String) throws {
        guard let data = token.data(using: .utf8) else {
            throw KeychainError.unhandled(status: errSecParam)
        }
        try keychain.set(data, forKey: tokenKey)
    }

    func loadToken() throws -> String? {
        guard let data = try keychain.data(forKey: tokenKey) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    func clear() throws {
        try keychain.removeValue(forKey: tokenKey)
    }
}
