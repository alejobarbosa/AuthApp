//
//  AppDependencies.swift
//  AuthApp
//
//  Created by Alejo Barbosa on 29/07/26.
//

import Foundation

@MainActor
final class AppDependencies {
    let sessionManager: SessionManager

    init() {
        // Hardcoded literal, not runtime input — force-unwrap is safe here.
        let baseURL = URL(string: "https://site.api-test.devmds.com")!

        let sessionStore = KeychainSessionStore()
        let apiClient = APIClient(
            baseURL: baseURL,
            authorizationInterceptor: SessionAuthorizationInterceptor(sessionStore: sessionStore)
        )
        let authRepository = AuthRepository(apiClient: apiClient)

        sessionManager = SessionManager(sessionStore: sessionStore, authRepository: authRepository)
    }

    func makeLoginViewModel() -> LoginViewModel {
        LoginViewModel(sessionManager: sessionManager)
    }
}
