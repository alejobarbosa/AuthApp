//
//  ErrorBanner.swift
//  AuthApp
//
//  Created by Alejo Barbosa on 29/07/26.
//

import SwiftUI

struct ErrorBanner: View {
    let message: String

    var body: some View {
        Text(message)
            .font(Typography.caption)
            .foregroundStyle(ColorPalette.error)
            .padding(8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(ColorPalette.error.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
    }
}
