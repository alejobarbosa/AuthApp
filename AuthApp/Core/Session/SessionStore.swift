//
//  SessionStore.swift
//  AuthApp
//
//  Created by Alejo Barbosa on 29/07/26.
//

protocol SessionStore: Sendable {
    func save(token: String) throws
    func loadToken() throws -> String?
    func clear() throws
}
