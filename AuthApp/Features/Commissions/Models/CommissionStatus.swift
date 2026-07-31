//
//  CommissionStatus.swift
//  AuthApp
//
//  Created by Alejo Barbosa on 31/07/26.
//

enum CommissionStatus: Equatable, Sendable {
    case pending
    case unknown(String)

    init(rawValue: String) {
        self = rawValue.lowercased() == "pending" ? .pending : .unknown(rawValue)
    }

    var displayName: String {
        switch self {
        case .pending:
            "Pending"
        case .unknown(let raw):
            raw.capitalized
        }
    }
}
