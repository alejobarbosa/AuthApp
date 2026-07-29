//
//  MockAuthRepository.swift
//  AuthApp
//
//  Created by Alejo Barbosa on 29/07/26.
//

@testable import AuthApp

final class MockAuthRepository: AuthRepositoryProtocol, @unchecked Sendable {
    private(set) var loginCallCount = 0
    var loginResult: (@Sendable () throws(AppError) -> String)?

    func login(email: String, password: String) async throws(AppError) -> String {
        loginCallCount += 1
        guard let loginResult else {
            fatalError("MockAuthRepository.loginResult must be set before use")
        }
        return try loginResult()
    }
}
