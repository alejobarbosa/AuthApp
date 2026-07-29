//
//  HTTPMethod.swift
//  AuthApp
//
//  Created by Alejo Barbosa on 28/07/26.
//

enum HTTPMethod: String, Equatable, Sendable {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}
