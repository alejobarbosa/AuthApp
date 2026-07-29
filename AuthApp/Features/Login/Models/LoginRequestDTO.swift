//
//  LoginRequestDTO.swift
//  AuthApp
//
//  Created by Alejo Barbosa on 29/07/26.
//

struct LoginRequestDTO: Encodable, Sendable {
    let email: String
    let password: String
}
