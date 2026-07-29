//
//  AppError.swift
//  AuthApp
//
//  Created by Alejo Barbosa on 29/07/26.
//

import Foundation

enum AppError: Error, Equatable, Sendable {
    case validation(String)
    case authentication(AuthenticationError)
    case connectivity
    case server(statusCode: Int)
    case decoding
    case unknown
}

extension AppError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .validation(let message):
            message
        case .authentication(let authenticationError):
            authenticationError.errorDescription
        case .connectivity:
            "Check your internet connection and try again."
        case .server:
            "Something went wrong on our end. Please try again in a moment."
        case .decoding:
            "We received an unexpected response. Please try again."
        case .unknown:
            "Something went wrong. Please try again."
        }
    }
}

extension AppError {
    static func mapping(
        _ networkError: NetworkError,
        unauthorizedMeans authenticationError: AuthenticationError
    ) -> AppError {
        switch networkError {
        case .transport:
            .connectivity
        case .unauthorized:
            .authentication(authenticationError)
        case .http(let status, _):
            .server(statusCode: status)
        case .decoding:
            .decoding
        case .invalidURL, .invalidResponse, .unknown, .emptyResponse:
            .unknown
        }
    }
}
