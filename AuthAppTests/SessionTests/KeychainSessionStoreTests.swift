//
//  KeychainSessionStoreTests.swift
//  AuthApp
//
//  Created by Alejo Barbosa on 31/07/26.
//

import Testing
@testable import AuthApp

@Suite("KeychainSessionStore", .serialized)
struct KeychainSessionStoreTests {

    private func makeStore() -> KeychainSessionStore {
        KeychainSessionStore(keychain: KeychainWrapper(service: "com.devmds.authapp.tests"))
    }

    @Test("Save then load round-trips the same token")
    func saveThenLoadRoundTrips() throws {
        let store = makeStore()
        try store.clear()

        try store.save(token: "test-token-123")

        #expect(try store.loadToken() == "test-token-123")

        try store.clear()
    }

    @Test("Loading with nothing saved returns nil, not an error")
    func loadWithNothingSavedReturnsNil() throws {
        let store = makeStore()
        try store.clear()

        #expect(try store.loadToken() == nil)
    }

    @Test("Clear removes a previously saved token")
    func clearRemovesToken() throws {
        let store = makeStore()
        try store.save(token: "to-be-cleared")

        try store.clear()

        #expect(try store.loadToken() == nil)
    }

    @Test("Saving twice overwrites rather than throwing a duplicate-item error")
    func savingTwiceOverwrites() throws {
        let store = makeStore()
        try store.clear()

        try store.save(token: "first")
        try store.save(token: "second")

        #expect(try store.loadToken() == "second")

        try store.clear()
    }
}
