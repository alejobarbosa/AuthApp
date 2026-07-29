//
//  SecureTextField.swift
//  AuthApp
//
//  Created by Alejo Barbosa on 29/07/26.
//

import SwiftUI

struct SecureTextField: View {
    let title: String
    @Binding var text: String

    var body: some View {
        SecureField(title, text: $text)
            .textFieldStyle(.roundedBorder)
    }
}
