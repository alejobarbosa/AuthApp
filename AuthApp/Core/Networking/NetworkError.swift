//
//  NetworkError.swift
//  AuthApp
//
//  Created by Alejo Barbosa on 28/07/26.
//

import Foundation

enum NetworkError: Error, Sendable {
    /// The endpoint's `path` could not be resolved into a valid URL.
    case invalidURL(path: String)

    /// URLSession-level failure (no connectivity, timeout, DNS, TLS, etc.).
    case transport(URLError)

    /// A non-2xx HTTP status was returned. `data` is preserved so a caller
    /// can attempt to decode the API's own error body.
    case http(status: Int, data: Data?)

    /// The response body could not be decoded into the expected type.
    case decoding(DecodingError)

    /// Reserved for operations where a body is expected but absent (e.g. a
    /// future 204 No Content). 
    case emptyResponse

    /// The operation requires authentication and no valid token was
    /// available, or the server rejected the token. 
    case unauthorized

    /// The response was not an `HTTPURLResponse` at all (should not happen
    /// with URLSession's HTTP(S) transport, but modeled rather than force-cast).
    case invalidResponse

    /// Anything else. Stores a sanitized description rather than the raw
    /// `Error` itself: an arbitrary caught `Error` existential isn't
    /// guaranteed `Sendable`, and this type must cross `async` boundaries
    /// cleanly under Swift 6 strict concurrency. A description string is
    /// also all `AppError`/logging ever needed from this case.
    case unknown(description: String)
}

extension NetworkError: Equatable {
    static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case let (.invalidURL(l), .invalidURL(r)):
            return l == r
        case let (.transport(l), .transport(r)):
            return l.code == r.code
        case let (.http(lStatus, lData), .http(rStatus, rData)):
            return lStatus == rStatus && lData == rData
        case (.decoding, .decoding):
            // DecodingError doesn't conform to Equatable; two decoding
            // failures are treated as equal for test-assertion purposes —
            // tests that need more precision match on the enum case via a
            // `guard case` instead of `==`.
            return true
        case (.emptyResponse, .emptyResponse),
             (.unauthorized, .unauthorized),
             (.invalidResponse, .invalidResponse):
            return true
        case let (.unknown(l), .unknown(r)):
            return l == r
        default:
            return false
        }
    }
}
