//
//  AuthAppApp.swift
//  AuthApp
//
//  Created by Alejo Barbosa on 28/07/26.
//

import SwiftUI

@main
struct AuthAppApp: App {
    @State private var coordinator = AppCoordinator()

    var body: some Scene {
        WindowGroup {
            RootView(coordinator: coordinator)
        }
    }
}
