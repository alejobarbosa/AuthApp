//
//  SessionAuthorizationInterceptor.swift
//  AuthApp
//
//  Created by Alejo Barbosa on 29/07/26.
//

struct SessionAuthorizationInterceptor: AuthorizationInterceptor {
    private let sessionStore: SessionStore

    init(sessionStore: SessionStore) {
        self.sessionStore = sessionStore
    }

    func currentToken() async -> String? {
        try? sessionStore.loadToken()
    }
}
