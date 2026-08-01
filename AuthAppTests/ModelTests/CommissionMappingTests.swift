//
//  CommissionMappingTests.swift
//  AuthApp
//
//  Created by Alejo Barbosa on 31/07/26.
//

import Foundation
import Testing
@testable import AuthApp

@Suite("Commission mapping")
struct CommissionMappingTests {

    private func makeDTO(buildCost: String = "45000.00", status: String = "pending") -> CommissionDTO {
        CommissionDTO(
            id: "1",
            carModel: "Mustang GT",
            carBrand: "Ford",
            buildCost: buildCost,
            commissionRate: "3.00",
            commissionAmount: "1350.00",
            status: status,
            createdAt: Date(timeIntervalSince1970: 0)
        )
    }

    @Test("Well-formed amounts convert to Decimal")
    func wellFormedAmountsConvert() {
        let commission = Commission(dto: makeDTO())

        #expect(commission.buildCost == Decimal(string: "45000.00"))
        #expect(commission.commissionAmount == Decimal(string: "1350.00"))
    }

    @Test("An unparseable amount maps to nil, not zero and not a crash")
    func unparseableAmountMapsToNil() {
        let commission = Commission(dto: makeDTO(buildCost: "N/A"))

        #expect(commission.buildCost == nil)
    }

    @Test("A known status maps to .pending, case-insensitively")
    func knownStatusMaps() {
        #expect(CommissionStatus(rawValue: "pending") == .pending)
        #expect(CommissionStatus(rawValue: "Pending") == .pending)
    }

    @Test("An unfamiliar status falls back to .unknown, preserving the raw value")
    func unfamiliarStatusFallsBack() {
        let status = CommissionStatus(rawValue: "archived")

        guard case .unknown(let raw) = status else {
            Issue.record("Expected .unknown, got \(status)")
            return
        }
        #expect(raw == "archived")
    }
}
