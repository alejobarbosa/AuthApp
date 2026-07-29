//
//  AuthRepository.swift
//  AuthApp
//
//  Created by Alejo Barbosa on 29/07/26.
//

final class AuthRepository: AuthRepositoryProtocol {
    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    func login(email: String, password: String) async throws(AppError) -> String {
        do {
            let response: AuthResponseDTO = try await apiClient.send(
                AuthEndpoint.login(email: email, password: password)
            )
            return response.accessToken
        } catch let error as NetworkError {
            throw AppError.mapping(error, unauthorizedMeans: .invalidCredentials)
        } catch {
            throw AppError.unknown
        }
    }
}
