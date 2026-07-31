//
//  CommissionsRepositoryProtocol.swift
//  AuthApp
//
//  Created by Alejo Barbosa on 31/07/26.
//

protocol CommissionsRepositoryProtocol: Sendable {
    func fetchAll() async throws(AppError) -> [Commission]
}
