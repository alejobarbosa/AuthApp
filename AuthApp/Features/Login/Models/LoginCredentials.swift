//
//  LoginCredentials.swift
//  AuthApp
//
//  Created by Alejo Barbosa on 29/07/26.
//

import Foundation

struct LoginCredentials: Equatable, Sendable {
    var email = ""
    var password = ""

    func validate() -> String? {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedEmail.isEmpty || password.isEmpty {
            return "Enter both your email and password."
        }
        if !trimmedEmail.contains("@") {
            return "Enter a valid email address."
        }
        return nil
    }
}
