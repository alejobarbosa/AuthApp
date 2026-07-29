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
