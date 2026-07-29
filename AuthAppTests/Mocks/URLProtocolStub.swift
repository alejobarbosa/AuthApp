//
//  URLProtocolStub.swift
//  AuthApp
//
//  Created by Alejo Barbosa on 28/07/26.
//

import Foundation

final class URLProtocolStub: URLProtocol, @unchecked Sendable {
    nonisolated(unsafe) static var stubResponseData: Data?
    nonisolated(unsafe) static var stubResponse: HTTPURLResponse?
    nonisolated(unsafe) static var stubError: Error?
    nonisolated(unsafe) static var requestHandler: ((URLRequest) -> Void)?

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        Self.requestHandler?(request)

        if let error = Self.stubError {
            client?.urlProtocol(self, didFailWithError: error)
            return
        }

        if let response = Self.stubResponse {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }

        if let data = Self.stubResponseData {
            client?.urlProtocol(self, didLoad: data)
        }

        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}

    /// Builds a `URLSession` wired to this stub, resetting stub state first
    /// so tests never leak configuration into one another.
    static func makeStubbedSession() -> URLSession {
        stubResponseData = nil
        stubResponse = nil
        stubError = nil
        requestHandler = nil

        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        return URLSession(configuration: configuration)
    }
}
