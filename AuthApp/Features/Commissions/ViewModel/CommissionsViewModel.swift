//
//  CommissionsViewModel.swift
//  AuthApp
//
//  Created by Alejo Barbosa on 31/07/26.
//

import Observation

enum CommissionsLoadState: Equatable, Sendable {
    case idle
    case loading
    case loaded([Commission])
    case failed(AppError)
}

@MainActor
@Observable
final class CommissionsViewModel {
    private(set) var loadState: CommissionsLoadState = .idle

    private let repository: CommissionsRepositoryProtocol
    private let sessionManager: SessionManager

    init(repository: CommissionsRepositoryProtocol, sessionManager: SessionManager) {
        self.repository = repository
        self.sessionManager = sessionManager
    }

    func load() async {
        guard loadState != .loading else { return }
        loadState = .loading

        do {
            let commissions = try await repository.fetchAll()
            loadState = .loaded(commissions)
        } catch AppError.authentication(.sessionExpired) {
            // Back to .idle, not left at .loading — otherwise a successful
            // re-login later would find load() permanently blocked by its
            // own duplicate-call guard above.
            loadState = .idle
            sessionManager.handleUnauthorizedResponse()
        } catch {
            loadState = .failed(error)
        }
    }

    func logout() {
        sessionManager.logout()
    }
}
