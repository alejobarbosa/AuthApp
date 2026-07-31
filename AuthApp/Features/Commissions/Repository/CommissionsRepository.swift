//
//  CommissionsRepository.swift
//  AuthApp
//
//  Created by Alejo Barbosa on 31/07/26.
//

final class CommissionsRepository: CommissionsRepositoryProtocol {
    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    func fetchAll() async throws(AppError) -> [Commission] {
        do {
            let response: CommissionListDTO = try await apiClient.send(CommissionsEndpoint.list)
            return response.commissions.map(Commission.init(dto:))
        } catch let error as NetworkError {
            throw AppError.mapping(error, unauthorizedMeans: .sessionExpired)
        } catch {
            throw AppError.unknown
        }
    }
}
