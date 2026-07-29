//
//  Endpoint.swift
//  AuthApp
//
//  Created by Alejo Barbosa on 28/07/26.
//

import Foundation

/// Describes a single network operation without performing it.
public protocol Endpoint: Sendable {
    /// Path relative to the API's base URL, e.g. "/auth/login".
    var path: String { get }

    /// HTTP verb for this operation.
    var method: HTTPMethod { get }

    /// Additional headers beyond what the request builder adds by default
    /// (Accept, Content-Type, Authorization).
    var headers: [String: String] { get }

    /// Pre-encoded request body, or `nil` for bodyless requests (GET, DELETE).
    var body: Data? { get }

    /// Whether this operation requires a Bearer token to be attached.
    /// When `true` and no token is available, `APIClient` fails fast with
    /// `NetworkError.unauthorized` instead of sending an unauthenticated request.
    var requiresAuth: Bool { get }
}

/// Default values so most endpoints only need to specify what differs.
///
/// Verified against the live Swagger contract: `POST /auth/login` requires no
/// auth and always has a body; `GET /commissions` and `GET /commissions/{id}`
/// require auth and have no body. 
public extension Endpoint {
    var headers: [String: String] { [:] }
    var body: Data? { nil }
    var requiresAuth: Bool { true }
}


