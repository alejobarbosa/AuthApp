//
//  LoginCredentialsTests.swift
//  AuthApp
//
//  Created by Alejo Barbosa on 31/07/26.
//

import Testing
@testable import AuthApp

@Suite("LoginCredentials")
struct LoginCredentialsTests {

    @Test("Both fields empty fails validation")
    func bothEmptyFails() {
        #expect(LoginCredentials(email: "", password: "").validate() != nil)
    }

    @Test("Empty email alone fails validation")
    func emptyEmailFails() {
        #expect(LoginCredentials(email: "", password: "secret").validate() != nil)
    }

    @Test("Empty password alone fails validation")
    func emptyPasswordFails() {
        #expect(LoginCredentials(email: "alice@example.com", password: "").validate() != nil)
    }

    @Test("Whitespace-only email is treated as empty")
    func whitespaceEmailFails() {
        let message = LoginCredentials(email: "   ", password: "secret").validate()
        #expect(message == "Enter both your email and password.")
    }

    @Test("Email without an @ fails with a distinct message")
    func emailWithoutAtFails() {
        let message = LoginCredentials(email: "alice.example.com", password: "secret").validate()
        #expect(message == "Enter a valid email address.")
    }

    @Test("Well-formed credentials pass validation")
    func validCredentialsPass() {
        #expect(LoginCredentials(email: "alice@example.com", password: "secret").validate() == nil)
    }
}
