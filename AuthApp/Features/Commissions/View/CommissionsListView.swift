//
//  CommissionsListView.swift
//  AuthApp
//
//  Created by Alejo Barbosa on 31/07/26.
//

import SwiftUI

struct CommissionsListView: View {
    var viewModel: CommissionsViewModel

    @State private var isShowingLogoutConfirmation = false

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Your Commissions")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Log Out") {
                            isShowingLogoutConfirmation = true
                        }
                    }
                }
        }
        .destructiveConfirmation(
            "Log out?",
            isPresented: $isShowingLogoutConfirmation,
            actionTitle: "Log Out"
        ) {
            viewModel.logout()
        }
        .task {
            await viewModel.load()
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.loadState {
        case .idle, .loading:
            LoadingOverlay()
        case .loaded(let commissions) where commissions.isEmpty:
            EmptyState(message: "No commissions yet.")
        case .loaded(let commissions):
            List(commissions) { commission in
                CommissionCard(commission: commission)
            }
        case .failed(let error):
            ErrorBanner(message: error.errorDescription ?? "Something went wrong.")
        }
    }
}
