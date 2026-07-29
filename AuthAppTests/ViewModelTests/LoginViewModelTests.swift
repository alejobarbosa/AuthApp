//
//  LoginViewModelTests.swift
//  AuthApp
//
//  Created by Alejo Barbosa on 29/07/26.
//

import Testing
@testable import AuthApp

@MainActor
@Suite("LoginViewModel")
struct LoginViewModelTests {

    @Test("Empty fields are caught before any repository call")
    func emptyFieldsFailValidation() async {
        let repository = MockAuthRepository()
        let sessionManager = SessionManager(sessionStore: MockSessionStore(), authRepository: repository)
        let viewModel = LoginViewModel(sessionManager: sessionManager)

        await viewModel.submit()

        #expect(viewModel.validationMessage != nil)
        #expect(repository.loginCallCount == 0)
    }

    @Test("Valid credentials submit through to the session manager")
    func validCredentialsSubmit() async {
        let repository = MockAuthRepository()
        repository.loginResult = { "token" }
        let sessionManager = SessionManager(sessionStore: MockSessionStore(), authRepository: repository)
        let viewModel = LoginViewModel(sessionManager: sessionManager)
        viewModel.credentials = LoginCredentials(email: "alice@example.com", password: "secret")

        await viewModel.submit()

        #expect(repository.loginCallCount == 1)
        #expect(sessionManager.state == .authenticated)
    }

    @Test("A failed login surfaces its message through errorMessage")
    func failedLoginSurfacesMessage() async {
        let repository = MockAuthRepository()
        repository.loginResult = { () throws(AppError) -> String in
            throw AppError.authentication(.invalidCredentials)
        }
        let sessionManager = SessionManager(sessionStore: MockSessionStore(), authRepository: repository)
        let viewModel = LoginViewModel(sessionManager: sessionManager)
        viewModel.credentials = LoginCredentials(email: "alice@example.com", password: "wrong")

        await viewModel.submit()

        #expect(viewModel.errorMessage == AppError.authentication(.invalidCredentials).errorDescription)
    }
}
