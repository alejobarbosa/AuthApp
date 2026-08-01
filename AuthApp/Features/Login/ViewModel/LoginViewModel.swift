//
//  LoginViewModel.swift
//  AuthApp
//
//  Created by Alejo Barbosa on 29/07/26.
//

import Observation

@MainActor
@Observable
final class LoginViewModel {
    var credentials = LoginCredentials()
    private(set) var validationMessage: String?

    private let sessionManager: SessionManager

    init(sessionManager: SessionManager) {
        self.sessionManager = sessionManager
    }

    var isSubmitting: Bool {
        sessionManager.state == .submitting
    }

    var errorMessage: String? {
        switch sessionManager.state {
        case .recoverableError(let error):
            error.errorDescription
        case .unauthorized:
            AuthenticationError.sessionExpired.errorDescription
        default:
            nil
        }
    }

    func submit() async {
        guard !isSubmitting else { return }
        validationMessage = nil

        if let message = credentials.validate() {
            validationMessage = message
            return
        }

        await sessionManager.login(email: credentials.email, password: credentials.password)
    }
}
