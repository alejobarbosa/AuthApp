//
//  Logger.swift
//  AuthApp
//
//  Created by Alejo Barbosa on 28/07/26.
//
// Thin wrapper around os.Logger. The point of routing everything through
// here: anything marked `sensitive` never gets logged in release builds,
// and is masked even in debug — no passwords/tokens/headers slip out
// because nothing else in the app is allowed to call print() or os.Logger
// directly.

import os

/// Severity levels this app actually uses. Kept smaller than `OSLogType`'s
/// full set so call sites don't have to reason about `.fault` vs `.error`
/// distinctions that don't matter for this project.
public enum LogLevel: Sendable {
    case debug
    case info
    case error

    var osLogType: OSLogType {
        switch self {
        case .debug: .debug
        case .info: .info
        case .error: .error
        }
    }
}

/// Redaction-aware logging facade.
///
/// `sensitive: true` messages are never emitted in release builds (`#if
/// DEBUG` gate) and are replaced with a fixed placeholder even in debug
/// builds — developers can see *that* a sensitive event happened without
/// ever seeing its contents in a console, screen recording, or crash log.
public struct Logger: Sendable {
    private let osLogger: os.Logger

    public init(category: String, subsystem: String = "com.devmds.authapp") {
        self.osLogger = os.Logger(subsystem: subsystem, category: category)
    }

    /// - Parameters:
    ///   - level: severity.
    ///   - message: human-readable message. Must never itself contain a
    ///     password, token, cookie, or Authorization header value — pass
    ///     `sensitive: true` instead of trying to redact the string yourself.
    ///   - sensitive: when `true`, `message` is discarded entirely; only the
    ///     fact that a sensitive event occurred is logged (debug builds only).
    public func log(_ level: LogLevel, _ message: String, sensitive: Bool) {
        guard !sensitive else {
            #if DEBUG
            osLogger.log(level: level.osLogType, "[REDACTED] sensitive event occurred")
            #endif
            return
        }
        osLogger.log(level: level.osLogType, "\(message, privacy: .public)")
    }
}

