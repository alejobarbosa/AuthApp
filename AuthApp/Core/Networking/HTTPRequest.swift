//
//  HTTPRequest.swift
//  AuthApp
//
//  Created by Alejo Barbosa on 28/07/26.
//

import Foundation

/// Builds `URLRequest` values from an `Endpoint`.
public enum HTTPRequestBuilder {

    /// - Parameters:
    ///   - endpoint: the operation to perform.
    ///   - baseURL: the API's base URL (e.g. https://site.api-test.devmds.com).
    ///   - bearerToken: token to attach when `endpoint.requiresAuth` is `true`.
    /// - Throws: `NetworkError.invalidURL` if the endpoint's path doesn't
    ///   resolve against `baseURL`; `NetworkError.unauthorized` if the
    ///   endpoint requires auth but no token was supplied.
    public static func build(
        endpoint: some Endpoint,
        baseURL: URL,
        bearerToken: String?
    ) throws(NetworkError) -> URLRequest {
        guard let url = URL(string: endpoint.path, relativeTo: baseURL) else {
            throw NetworkError.invalidURL(path: endpoint.path)
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.httpBody = endpoint.body
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if endpoint.body != nil {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        for (field, value) in endpoint.headers {
            request.setValue(value, forHTTPHeaderField: field)
        }

        if endpoint.requiresAuth {
            guard let bearerToken, !bearerToken.isEmpty else {
                throw NetworkError.unauthorized
            }
            request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        }

        return request
    }
}
