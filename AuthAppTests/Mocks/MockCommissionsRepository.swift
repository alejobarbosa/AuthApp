//
//  MockCommissionsRepository.swift
//  AuthApp
//
//  Created by Alejo Barbosa on 31/07/26.
//

@testable import AuthApp

final class MockCommissionsRepository: CommissionsRepositoryProtocol, @unchecked Sendable {
    private(set) var fetchAllCallCount = 0
    var fetchAllResult: (@Sendable () throws(AppError) -> [Commission])?

    func fetchAll() async throws(AppError) -> [Commission] {
        fetchAllCallCount += 1
        guard let fetchAllResult else {
            fatalError("MockCommissionsRepository.fetchAllResult must be set before use")
        }
        return try fetchAllResult()
    }
}
