//
//  AuthenticationError.swift
//  AuthApp
//
//  Created by Alejo Barbosa on 29/07/26.
//

import Foundation

enum AuthenticationError: Error, Equatable, Sendable {
    case invalidCredentials
    case sessionExpired
}

extension AuthenticationError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            "Incorrect email or password."
        case .sessionExpired:
            "Your session has expired. Please log in again."
        }
    }
}
