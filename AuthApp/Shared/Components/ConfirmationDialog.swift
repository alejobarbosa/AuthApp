//
//  ConfirmationDialog.swift
//  AuthApp
//
//  Created by Alejo Barbosa on 31/07/26.
//

import SwiftUI

private struct DestructiveConfirmationModifier: ViewModifier {
    let title: String
    @Binding var isPresented: Bool
    let actionTitle: String
    let action: () -> Void

    func body(content: Content) -> some View {
        content.confirmationDialog(title, isPresented: $isPresented, titleVisibility: .visible) {
            Button(actionTitle, role: .destructive, action: action)
            Button("Cancel", role: .cancel) {}
        }
    }
}

extension View {
    func destructiveConfirmation(
        _ title: String,
        isPresented: Binding<Bool>,
        actionTitle: String,
        action: @escaping () -> Void
    ) -> some View {
        modifier(DestructiveConfirmationModifier(
            title: title,
            isPresented: isPresented,
            actionTitle: actionTitle,
            action: action
        ))
    }
}
