//
//  AuthRepositoryProtocol.swift
//  AuthApp
//
//  Created by Alejo Barbosa on 29/07/26.
//

protocol AuthRepositoryProtocol: Sendable {
    func login(email: String, password: String) async throws(AppError) -> String
}
