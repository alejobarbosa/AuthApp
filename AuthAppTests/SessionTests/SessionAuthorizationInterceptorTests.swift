//
//  SessionAuthorizationInterceptorTests.swift
//  AuthApp
//
//  Created by Alejo Barbosa on 31/07/26.
//

import Testing
@testable import AuthApp

@Suite("SessionAuthorizationInterceptor")
struct SessionAuthorizationInterceptorTests {

    @Test("Returns the stored token when one exists")
    func returnsStoredToken() async {
        let store = MockSessionStore()
        store.seed(token: "stored-token")
        let interceptor = SessionAuthorizationInterceptor(sessionStore: store)

        #expect(await interceptor.currentToken() == "stored-token")
    }

    @Test("Returns nil when nothing is stored, never throws out to the caller")
    func returnsNilWhenEmpty() async {
        let store = MockSessionStore()
        let interceptor = SessionAuthorizationInterceptor(sessionStore: store)

        #expect(await interceptor.currentToken() == nil)
    }
}
