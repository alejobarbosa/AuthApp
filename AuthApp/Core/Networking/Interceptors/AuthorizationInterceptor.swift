//
//  AuthorizationInterceptor.swift
//  AuthApp
//
//  Created by Alejo Barbosa on 28/07/26.
//
// Supplies the bearer token to APIClient without APIClient knowing where it comes from.
 
/// Supplies the bearer token for authenticated requests.
protocol AuthorizationInterceptor: Sendable {
    /// The current bearer token, or `nil` if there is no active session.
    func currentToken() async -> String?
}
 
/// Interceptor for endpoints that don't need a real session — e.g. the
/// login call itself, which is unauthenticated — and the default used
/// wherever an `APIClient` is constructed without an explicit session
/// dependency (mainly in tests).
struct NoAuthorizationInterceptor: AuthorizationInterceptor {
    init() {}
    func currentToken() async -> String? { nil }
}


