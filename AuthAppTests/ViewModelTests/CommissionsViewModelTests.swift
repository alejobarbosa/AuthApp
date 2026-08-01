//
//  CommissionsViewModelTests.swift
//  AuthApp
//
//  Created by Alejo Barbosa on 31/07/26.
//

import Foundation
import Testing
@testable import AuthApp

@MainActor
@Suite("CommissionsViewModel")
struct CommissionsViewModelTests {

    private func makeCommission() -> Commission {
        Commission(dto: CommissionDTO(
            id: "1",
            carModel: "Mustang GT",
            carBrand: "Ford",
            buildCost: "45000.00",
            commissionRate: "3.00",
            commissionAmount: "1350.00",
            status: "pending",
            createdAt: Date(timeIntervalSince1970: 0)
        ))
    }

    @Test("Successful load populates the list")
    func loadSuccess() async {
        let repository = MockCommissionsRepository()
        let commission = makeCommission()
        repository.fetchAllResult = { [commission] }
        let sessionManager = SessionManager(sessionStore: MockSessionStore(), authRepository: MockAuthRepository())
        let viewModel = CommissionsViewModel(repository: repository, sessionManager: sessionManager)

        await viewModel.load()

        guard case .loaded(let commissions) = viewModel.loadState else {
            Issue.record("Expected .loaded, got \(viewModel.loadState)")
            return
        }
        #expect(commissions.count == 1)
    }

    @Test("A session-expired error clears the session and routes to unauthorized")
    func sessionExpiredTriggersUnauthorized() async {
        let repository = MockCommissionsRepository()
        repository.fetchAllResult = { () throws(AppError) -> [Commission] in
            throw AppError.authentication(.sessionExpired)
        }
        let store = MockSessionStore()
        store.seed(token: "existing-token")
        let sessionManager = SessionManager(sessionStore: store, authRepository: MockAuthRepository())
        sessionManager.restoreSession()
        let viewModel = CommissionsViewModel(repository: repository, sessionManager: sessionManager)

        await viewModel.load()

        #expect(sessionManager.state == .unauthorized)
        #expect(store.savedToken == nil)
    }

    @Test("A session-expired error resets loadState instead of leaving it stuck loading")
    func sessionExpiredResetsLoadState() async {
        let repository = MockCommissionsRepository()
        repository.fetchAllResult = { () throws(AppError) -> [Commission] in
            throw AppError.authentication(.sessionExpired)
        }
        let sessionManager = SessionManager(sessionStore: MockSessionStore(), authRepository: MockAuthRepository())
        let viewModel = CommissionsViewModel(repository: repository, sessionManager: sessionManager)

        await viewModel.load()

        #expect(viewModel.loadState == .idle)
    }

    @Test("A server error is surfaced as a failed load state")
    func serverErrorSurfacesAsFailed() async {
        let repository = MockCommissionsRepository()
        repository.fetchAllResult = { () throws(AppError) -> [Commission] in
            throw AppError.server(statusCode: 500)
        }
        let sessionManager = SessionManager(sessionStore: MockSessionStore(), authRepository: MockAuthRepository())
        let viewModel = CommissionsViewModel(repository: repository, sessionManager: sessionManager)

        await viewModel.load()

        guard case .failed(let error) = viewModel.loadState else {
            Issue.record("Expected .failed, got \(viewModel.loadState)")
            return
        }
        #expect(error == .server(statusCode: 500))
    }

    @Test("Logout delegates to the session manager")
    func logoutDelegatesToSessionManager() {
        let repository = MockCommissionsRepository()
        let store = MockSessionStore()
        store.seed(token: "existing-token")
        let sessionManager = SessionManager(sessionStore: store, authRepository: MockAuthRepository())
        sessionManager.restoreSession()
        let viewModel = CommissionsViewModel(repository: repository, sessionManager: sessionManager)

        viewModel.logout()

        #expect(sessionManager.state == .loggedOut)
        #expect(store.savedToken == nil)
    }
}
