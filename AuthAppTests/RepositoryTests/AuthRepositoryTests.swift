//
//  AuthRepositoryTests.swift
//  AuthApp
//
//  Created by Alejo Barbosa on 29/07/26.
//

import Foundation
import Testing
@testable import AuthApp

@Suite("AuthRepository")
struct AuthRepositoryTests {

    @Test("Successful login returns the access token")
    func loginSuccess() async throws {
        let mockClient = MockAPIClient()
        mockClient.resultProvider = { AuthResponseDTO(accessToken: "abc123") }
        let repository = AuthRepository(apiClient: mockClient)

        let token = try await repository.login(email: "alice@example.com", password: "secret")

        #expect(token == "abc123")
    }

    @Test("Invalid credentials map to AppError.authentication(.invalidCredentials)")
    func loginUnauthorized() async {
        let mockClient = MockAPIClient()
        mockClient.resultProvider = { throw NetworkError.unauthorized }
        let repository = AuthRepository(apiClient: mockClient)

        do {
            _ = try await repository.login(email: "alice@example.com", password: "wrong")
            Issue.record("Expected AppError.authentication, got success")
        } catch {
            #expect(error == .authentication(.invalidCredentials))
        }
    }

    @Test("A connectivity failure maps to AppError.connectivity")
    func loginConnectivityFailure() async {
        let mockClient = MockAPIClient()
        mockClient.resultProvider = { throw NetworkError.transport(URLError(.notConnectedToInternet)) }
        let repository = AuthRepository(apiClient: mockClient)

        do {
            _ = try await repository.login(email: "alice@example.com", password: "secret")
            Issue.record("Expected AppError.connectivity, got success")
        } catch {
            #expect(error == .connectivity)
        }
    }

    @Test("A malformed response maps to AppError.decoding")
    func loginDecodingFailure() async {
        let mockClient = MockAPIClient()
        mockClient.resultProvider = {
            throw NetworkError.decoding(
                DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "test"))
            )
        }
        let repository = AuthRepository(apiClient: mockClient)

        do {
            _ = try await repository.login(email: "alice@example.com", password: "secret")
            Issue.record("Expected AppError.decoding, got success")
        } catch {
            #expect(error == .decoding)
        }
    }
}
