//
//  LoginView.swift
//  AuthApp
//
//  Created by Alejo Barbosa on 29/07/26.
//

import SwiftUI

struct LoginView: View {
    @Bindable var viewModel: LoginViewModel

    var body: some View {
        VStack(spacing: 16) {
            Text("Sign in")
                .font(Typography.title)

            LabeledTextField(title: "Email", text: $viewModel.credentials.email)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)

            SecureTextField(title: "Password", text: $viewModel.credentials.password)

            if let validationMessage = viewModel.validationMessage {
                ErrorBanner(message: validationMessage)
            }

            if let errorMessage = viewModel.errorMessage {
                ErrorBanner(message: errorMessage)
            }

            PrimaryButton(title: "Log In", isLoading: viewModel.isSubmitting) {
                Task { await viewModel.submit() }
            }
        }
        .padding()
        .overlay {
            if viewModel.isSubmitting {
                LoadingOverlay()
            }
        }
    }
}


#if DEBUG
#Preview("Empty state") {
    LoginView(viewModel: LoginViewModel(sessionManager: .preview))
}

#Preview("Validation error") {
    let viewModel = LoginViewModel(sessionManager: .preview)
    LoginView(viewModel: viewModel)
        .task { await viewModel.submit() }
}

#Preview("Invalid credentials") {
    let loginResult: @Sendable () async throws(AppError) -> String = { () async throws(AppError) -> String in
        throw AppError.authentication(.invalidCredentials)
    }
    let viewModel = LoginViewModel(sessionManager: .preview(loginResult: loginResult))
    LoginView(viewModel: viewModel)
        .task {
            viewModel.credentials = LoginCredentials(email: "alice@example.com", password: "wrong")
            await viewModel.submit()
        }
}

#Preview("Submitting") {
    let loginResult: @Sendable () async throws(AppError) -> String = { () async throws(AppError) -> String in
        try? await Task.sleep(for: .seconds(999))
        return "unreachable"
    }
    let viewModel = LoginViewModel(sessionManager: .preview(loginResult: loginResult))
    LoginView(viewModel: viewModel)
        .task {
            viewModel.credentials = LoginCredentials(email: "alice@example.com", password: "secret")
            await viewModel.submit()
        }
}

private extension SessionManager {
    static var preview: SessionManager {
        preview { "preview-token" }
    }

    static func preview(loginResult: @escaping @Sendable () async throws(AppError) -> String) -> SessionManager {
        SessionManager(sessionStore: PreviewSessionStore(), authRepository: PreviewAuthRepository(loginResult: loginResult))
    }
}

private struct PreviewSessionStore: SessionStore {
    func save(token: String) throws {}
    func loadToken() throws -> String? { nil }
    func clear() throws {}
}

private struct PreviewAuthRepository: AuthRepositoryProtocol {
    let loginResult: @Sendable () async throws(AppError) -> String

    func login(email: String, password: String) async throws(AppError) -> String {
        try await loginResult()
    }
}
#endif
