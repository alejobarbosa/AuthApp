//
//  RetryPolicyTests.swift
//  AuthApp
//
//  Created by Alejo Barbosa on 31/07/26.
//

import Foundation
import Testing
@testable import AuthApp

@Suite("RetryPolicy")
struct RetryPolicyTests {

    @Test(".default retries transport failures")
    func defaultRetriesTransportFailures() {
        let error = NetworkError.transport(URLError(.notConnectedToInternet))
        #expect(RetryPolicy.default.shouldRetry(error, attempt: 1))
    }

    @Test(".default does not retry HTTP errors")
    func defaultDoesNotRetryHTTPErrors() {
        let error = NetworkError.http(status: 500, data: nil)
        #expect(!RetryPolicy.default.shouldRetry(error, attempt: 1))
    }

    @Test(".default does not retry decoding errors")
    func defaultDoesNotRetryDecodingErrors() {
        let context = DecodingError.Context(codingPath: [], debugDescription: "test")
        let error = NetworkError.decoding(.dataCorrupted(context))
        #expect(!RetryPolicy.default.shouldRetry(error, attempt: 1))
    }

    @Test(".default stops once maxAttempts is reached")
    func defaultStopsAtMaxAttempts() {
        let error = NetworkError.transport(URLError(.timedOut))
        #expect(!RetryPolicy.default.shouldRetry(error, attempt: 3))
    }

    @Test(".noRetry never retries, even a transport failure")
    func noRetryNeverRetries() {
        let error = NetworkError.transport(URLError(.timedOut))
        #expect(!RetryPolicy.noRetry.shouldRetry(error, attempt: 1))
    }

    @Test("Delay doubles with each attempt")
    func delayDoublesWithAttempt() {
        #expect(RetryPolicy.default.delay(forAttempt: 1) == .milliseconds(300))
        #expect(RetryPolicy.default.delay(forAttempt: 2) == .milliseconds(600))
        #expect(RetryPolicy.default.delay(forAttempt: 3) == .milliseconds(1200))
    }
}
