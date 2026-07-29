//
//  SessionManagerTests.swift
//  AuthApp
//
//  Created by Alejo Barbosa on 29/07/26.
//

import Testing
@testable import AuthApp

@MainActor
@Suite("SessionManager")
struct SessionManagerTests {

    @Test("Restoring with a saved token goes straight to authenticated")
    func restoresWithExistingToken() {
        let store = MockSessionStore()
        store.seed(token: "existing-token")
        let manager = SessionManager(sessionStore: store, authRepository: MockAuthRepository())

        manager.restoreSession()

        #expect(manager.state == .authenticated)
    }

    @Test("Restoring with nothing saved lands on loggedOut")
    func restoresWithNoToken() {
        let store = MockSessionStore()
        let manager = SessionManager(sessionStore: store, authRepository: MockAuthRepository())

        manager.restoreSession()

        #expect(manager.state == .loggedOut)
    }

    @Test("A successful login stores the token and moves to authenticated")
    func loginSuccessPersistsToken() async {
        let store = MockSessionStore()
        let repository = MockAuthRepository()
        repository.loginResult = { "new-token" }
        let manager = SessionManager(sessionStore: store, authRepository: repository)

        await manager.login(email: "alice@example.com", password: "secret")

        #expect(manager.state == .authenticated)
        #expect(store.savedToken == "new-token")
    }

    @Test("A failed login is recoverable and stores nothing")
    func loginFailureIsRecoverable() async {
        let store = MockSessionStore()
        let repository = MockAuthRepository()
        repository.loginResult = { () throws(AppError) -> String in
            throw AppError.authentication(.invalidCredentials)
        }
        let manager = SessionManager(sessionStore: store, authRepository: repository)

        await manager.login(email: "alice@example.com", password: "wrong")

        #expect(manager.state == .recoverableError(.authentication(.invalidCredentials)))
        #expect(store.savedToken == nil)
    }

    @Test("A second login call while submitting is ignored")
    func duplicateSubmitIsIgnored() async {
        let store = MockSessionStore()
        let repository = MockAuthRepository()
        repository.loginResult = { "token" }
        let manager = SessionManager(sessionStore: store, authRepository: repository)

        async let first: Void = manager.login(email: "a@example.com", password: "secret")
        async let second: Void = manager.login(email: "a@example.com", password: "secret")
        _ = await (first, second)

        #expect(repository.loginCallCount == 1)
    }

    @Test("Logout clears the stored token and returns to loggedOut")
    func logoutClearsSession() {
        let store = MockSessionStore()
        store.seed(token: "existing-token")
        let manager = SessionManager(sessionStore: store, authRepository: MockAuthRepository())
        manager.restoreSession()

        manager.logout()

        #expect(manager.state == .loggedOut)
        #expect(store.savedToken == nil)
    }
}
