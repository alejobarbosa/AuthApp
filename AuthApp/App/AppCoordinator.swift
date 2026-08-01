//
//  AppCoordinator.swift
//  AuthApp
//
//  Created by Alejo Barbosa on 29/07/26.
//

import Observation

@MainActor
@Observable
final class AppCoordinator {
    let dependencies: AppDependencies
    let loginViewModel: LoginViewModel
    let commissionsViewModel: CommissionsViewModel

    init(dependencies: AppDependencies = AppDependencies()) {
        self.dependencies = dependencies
        self.loginViewModel = dependencies.makeLoginViewModel()
        self.commissionsViewModel = dependencies.makeCommissionsViewModel()
    }

    var sessionState: SessionState {
        dependencies.sessionManager.state
    }

    func start() {
        dependencies.sessionManager.restoreSession()
    }
}
