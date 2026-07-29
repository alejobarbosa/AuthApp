//
//  SessionManager.swift
//  AuthApp
//
//  Created by Alejo Barbosa on 29/07/26.
//

import Observation

enum SessionState: Equatable, Sendable {
    case restoringSession
    case loggedOut
    case submitting
    case authenticated
    case recoverableError(AppError)
    case unauthorized
}

@MainActor
@Observable
final class SessionManager {
    private(set) var state: SessionState = .restoringSession

    private let sessionStore: SessionStore
    private let authRepository: AuthRepositoryProtocol

    init(sessionStore: SessionStore, authRepository: AuthRepositoryProtocol) {
        self.sessionStore = sessionStore
        self.authRepository = authRepository
    }

    /// Call once at launch. There's no "validate this token" endpoint
    /// documented, so a stored token just means "log the user straight
    /// in" — actual validity only gets confirmed the next time a protected
    /// call is made, via `handleUnauthorizedResponse`.
    func restoreSession() {
        let token = try? sessionStore.loadToken()
        if let token, !token.isEmpty {
            state = .authenticated
        } else {
            state = .loggedOut
        }
    }

    func login(email: String, password: String) async {
        guard state != .submitting else { return }
        state = .submitting

        do {
            let token = try await authRepository.login(email: email, password: password)
            try sessionStore.save(token: token)
            state = .authenticated
        } catch let error as AppError {
            state = .recoverableError(error)
        } catch {
            // Login itself succeeded but persisting the token failed — an
            // "authenticated" state that won't survive relaunch is worse
            // than just asking the user to try again.
            state = .recoverableError(.unknown)
        }
    }

    /// A protected request came back 401. There's no refresh endpoint to
    /// fall back on, so the only correct move is to drop the session and
    /// send the user back to login.
    func handleUnauthorizedResponse() {
        try? sessionStore.clear()
        state = .unauthorized
    }

    func logout() {
        try? sessionStore.clear()
        state = .loggedOut
    }
}
