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
                CommissionsListView(viewModel: coordinator.commissionsViewModel)
            case .loggedOut, .submitting, .recoverableError, .unauthorized:
                LoginView(viewModel: coordinator.loginViewModel)
            }
        }
        .task {
            coordinator.start()
        }
    }
}
