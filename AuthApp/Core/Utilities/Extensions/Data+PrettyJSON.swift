//
//  Data+PrettyJSON.swift
//  AuthApp
//
//  Created by Alejo Barbosa on 28/07/26.
//
// Debug-only pretty-printer for JSON bodies (mostly the API's own
// `{ message, statusCode }` error shape). Doesn't decide what's safe to
// log — that call is still on whoever's calling Logger.

import Foundation

extension Data {
    /// A pretty-printed string representation for debug logging, or `nil` if
    /// `self` isn't valid JSON. Never throws — logging must never be the
    /// reason a request pipeline fails.
    var prettyPrintedJSONForDebugLogging: String? {
        guard
            let object = try? JSONSerialization.jsonObject(with: self),
            let prettyData = try? JSONSerialization.data(
                withJSONObject: object,
                options: [.prettyPrinted, .sortedKeys]
            ),
            let string = String(data: prettyData, encoding: .utf8)
        else {
            return nil
        }
        return string
    }
}
