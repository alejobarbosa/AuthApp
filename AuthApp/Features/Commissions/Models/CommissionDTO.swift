//
//  CommissionDTO.swift
//  AuthApp
//
//  Created by Alejo Barbosa on 31/07/26.
//

import Foundation

struct CommissionDTO: Decodable, Sendable {
    let id: String
    let carModel: String
    let carBrand: String
    let buildCost: String
    let commissionRate: String
    let commissionAmount: String
    let status: String
    let createdAt: Date
}

struct CommissionListDTO: Decodable, Sendable {
    let commissions: [CommissionDTO]

    init(commissions: [CommissionDTO]) {
        self.commissions = commissions
    }

    private struct Element: Decodable {
        let commission: CommissionDTO?

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            commission = try? container.decode(CommissionDTO.self)
        }
    }

    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        var decoded: [CommissionDTO] = []
        while !container.isAtEnd {
            let wrapper = try container.decode(Element.self)
            if let commission = wrapper.commission {
                decoded.append(commission)
            }
        }
        commissions = decoded
    }
}
