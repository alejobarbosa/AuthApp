//
//  AuthEndpoint.swift
//  AuthApp
//
//  Created by Alejo Barbosa on 29/07/26.
//

import Foundation

enum AuthEndpoint: Endpoint {
    case login(email: String, password: String)

    var path: String {
        switch self {
        case .login: "/auth/login"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .login: .post
        }
    }

    var body: Data? {
        switch self {
        case .login(let email, let password):
            try? JSONEncoder().encode(LoginRequestDTO(email: email, password: password))
        }
    }

    var requiresAuth: Bool {
        switch self {
        case .login: false
        }
    }
}
