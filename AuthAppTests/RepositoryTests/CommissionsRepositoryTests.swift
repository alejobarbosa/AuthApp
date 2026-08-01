//
//  CommissionsRepositoryTests.swift
//  AuthApp
//
//  Created by Alejo Barbosa on 31/07/26.
//

import Foundation
import Testing
@testable import AuthApp

@Suite("CommissionsRepository")
struct CommissionsRepositoryTests {

    private func makeDTO(id: String = "1") -> CommissionDTO {
        CommissionDTO(
            id: id,
            carModel: "Mustang GT",
            carBrand: "Ford",
            buildCost: "45000.00",
            commissionRate: "3.00",
            commissionAmount: "1350.00",
            status: "pending",
            createdAt: Date(timeIntervalSince1970: 0)
        )
    }

    @Test("Successful fetch maps DTOs to domain commissions")
    func fetchAllSuccess() async throws {
        let mockClient = MockAPIClient()
        let dto = makeDTO()
        mockClient.resultProvider = { CommissionListDTO(commissions: [dto]) }
        let repository = CommissionsRepository(apiClient: mockClient)

        let commissions = try await repository.fetchAll()

        #expect(commissions.count == 1)
        #expect(commissions[0].carModel == "Mustang GT")
        #expect(commissions[0].commissionAmount == Decimal(string: "1350.00"))
    }

    @Test("A malformed entry is dropped without failing the whole list")
    func lenientListDecodingDropsBadEntries() throws {
        let json = """
        [
            {"id":"1","carModel":"Mustang GT","carBrand":"Ford","buildCost":"45000.00","commissionRate":"3.00","commissionAmount":"1350.00","status":"pending","createdAt":"2026-01-01T00:00:00Z"},
            {"id":"2","carModel":"missing required fields"},
            {"id":"3","carModel":"Civic Type R","carBrand":"Honda","buildCost":"38000.00","commissionRate":"2.50","commissionAmount":"950.00","status":"pending","createdAt":"2026-02-01T00:00:00Z"}
        ]
        """.data(using: .utf8)!

        let decoded = try JSONDecoder.apiDecoder.decode(CommissionListDTO.self, from: json)

        #expect(decoded.commissions.count == 2)
        #expect(decoded.commissions.map(\.id) == ["1", "3"])
    }

    @Test("401 maps to sessionExpired, not invalidCredentials")
    func fetchAllUnauthorized() async {
        let mockClient = MockAPIClient()
        mockClient.resultProvider = { throw NetworkError.unauthorized }
        let repository = CommissionsRepository(apiClient: mockClient)

        do {
            _ = try await repository.fetchAll()
            Issue.record("Expected AppError.authentication(.sessionExpired), got success")
        } catch {
            #expect(error == .authentication(.sessionExpired))
        }
    }
}
