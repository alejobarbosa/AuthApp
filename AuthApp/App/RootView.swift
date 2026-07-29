//
//  RootView.swift
//  AuthApp
//
//  Created by Alejo Barbosa on 29/07/26.
//

import SwiftUI

struct RootView: View {
    var coordinator: AppCoordinator

    var body: some View {
        Group {
            switch coordinator.sessionState {
            case .restoringSession:
                LoadingOverlay()
            case .authenticated:
                Text("Signed in — the commissions screen lands next.")
                    .padding()
            case .loggedOut, .submitting, .recoverableError, .unauthorized:
                LoginView(viewModel: coordinator.loginViewModel)
            }
        }
        .task {
            coordinator.start()
        }
    }
}
