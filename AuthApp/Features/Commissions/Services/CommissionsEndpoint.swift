//
//  CommissionsEndpoint.swift
//  AuthApp
//
//  Created by Alejo Barbosa on 31/07/26.
//

enum CommissionsEndpoint: Endpoint {
    case list

    var path: String {
        switch self {
        case .list: "/commissions"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .list: .get
        }
    }
}
