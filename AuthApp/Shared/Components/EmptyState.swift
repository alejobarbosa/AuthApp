//
//  EmptyState.swift
//  AuthApp
//
//  Created by Alejo Barbosa on 31/07/26.
//

import SwiftUI

struct EmptyState: View {
    let message: String

    var body: some View {
        ContentUnavailableView(message, systemImage: "tray")
    }
}
