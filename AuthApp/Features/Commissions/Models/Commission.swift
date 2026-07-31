//
//  Commission.swift
//  AuthApp
//
//  Created by Alejo Barbosa on 31/07/26.
//

import Foundation

struct Commission: Equatable, Sendable, Identifiable {
    let id: String
    let carModel: String
    let carBrand: String
    let buildCost: Decimal?
    let commissionRate: Decimal?
    let commissionAmount: Decimal?
    let status: CommissionStatus
    let createdAt: Date

    init(dto: CommissionDTO) {
        id = dto.id
        carModel = dto.carModel
        carBrand = dto.carBrand
        buildCost = Decimal(string: dto.buildCost)
        commissionRate = Decimal(string: dto.commissionRate)
        commissionAmount = Decimal(string: dto.commissionAmount)
        status = CommissionStatus(rawValue: dto.status)
        createdAt = dto.createdAt
    }
}
