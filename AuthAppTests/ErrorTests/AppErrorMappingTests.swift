//
//  AppErrorMappingTests.swift
//  AuthApp
//
//  Created by Alejo Barbosa on 31/07/26.
//

import Foundation
import Testing
@testable import AuthApp

@Suite("AppError.mapping")
struct AppErrorMappingTests {

    @Test("Transport failures map to .connectivity")
    func transportMapsToConnectivity() {
        let error = NetworkError.transport(URLError(.notConnectedToInternet))
        #expect(AppError.mapping(error, unauthorizedMeans: .invalidCredentials) == .connectivity)
    }

    @Test("Unauthorized maps to whatever meaning the caller specifies")
    func unauthorizedMapsToCallerMeaning() {
        #expect(AppError.mapping(.unauthorized, unauthorizedMeans: .invalidCredentials) == .authentication(.invalidCredentials))
        #expect(AppError.mapping(.unauthorized, unauthorizedMeans: .sessionExpired) == .authentication(.sessionExpired))
    }

    @Test("HTTP errors map to .server with the status code preserved")
    func httpMapsToServerWithStatusCode() {
        let error = NetworkError.http(status: 500, data: nil)
        #expect(AppError.mapping(error, unauthorizedMeans: .invalidCredentials) == .server(statusCode: 500))
    }

    @Test("Decoding failures map to .decoding")
    func decodingMapsToDecoding() {
        let context = DecodingError.Context(codingPath: [], debugDescription: "test")
        let error = NetworkError.decoding(.dataCorrupted(context))
        #expect(AppError.mapping(error, unauthorizedMeans: .invalidCredentials) == .decoding)
    }

    @Test("Every remaining case falls back to .unknown")
    func remainingCasesMapToUnknown() {
        #expect(AppError.mapping(.invalidURL(path: "/bad"), unauthorizedMeans: .invalidCredentials) == .unknown)
        #expect(AppError.mapping(.invalidResponse, unauthorizedMeans: .invalidCredentials) == .unknown)
        #expect(AppError.mapping(.emptyResponse, unauthorizedMeans: .invalidCredentials) == .unknown)
        #expect(AppError.mapping(.unknown(description: "x"), unauthorizedMeans: .invalidCredentials) == .unknown)
    }
}
