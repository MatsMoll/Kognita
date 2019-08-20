import XCTest
@testable import App
import Vapor
import FluentPostgreSQL
@testable import KognitaCore

class UserTests: VaporTestCase {
    
    private let path = "api/users"
    
    
    func testLoginSuccess() throws {

        let user = try User.create(email: "test@1.com", on: conn)

        var headers = standardHeaders
        headers.add(name: .authorization, value: "Basic dGVzdEAxLmNvbTpwYXNzd29yZA==")
        let response = try app.sendRequest(to: path + "/login", method: .POST, headers: headers)
        XCTAssert(response.http.status == .ok, "This should not return an error")

        let token = try response.content.syncDecode(UserToken.self)
        XCTAssert(token.userID == user.id, "The user id is not equal to the logged in user")
    }
    
    func testLoginFail() throws {

        _ = try User.create(on: conn)

        var headers = standardHeaders
        headers.add(name: .authorization, value: "Basic dGVzdEAxLmNvbTpwYXNzd29y")
        let response = try app.sendRequest(to: path + "/login", method: .POST, headers: headers)

        XCTAssert(response.http.status == .unauthorized, "This should not return an error")
    }
    
    
    func testCreateUserSuccess() throws {

        _ = try User.create(on: conn)

        let newUser = CreateUserRequest(name: "Mats", email: "test@3.com", password: "password", verifyPassword: "password", acceptedTermsInput: "on")
        let response = try app.sendRequest(to: path, method: .POST, headers: standardHeaders, body: newUser)
        XCTAssert(response.http.status == .ok, "This should not return an error code: \(response.http.status)")

        let user = try response.content.syncDecode(UserResponse.self)
        XCTAssert(user.name == newUser.name, "The name is different: \(user.name)")
        XCTAssert(user.email == newUser.email, "The email is different: \(user.email)")
    }
    
    func testCreateUserExistingEmail() throws {

        let user = try User.create(on: conn)
        let newUser = CreateUserRequest(name: "Mats", email: user.email, password: "password", verifyPassword: "password", acceptedTermsInput: "on")
        let response = try app.sendRequest(to: path, method: .POST, headers: standardHeaders, body: newUser)
        XCTAssert(response.http.status == .internalServerError, "This should return an error code, returned: \(response.http.status)")
    }
    
    func testCreateUserPasswordMismatch() throws {
        let newUser = CreateUserRequest(name: "Mats", email: "test@3.com", password: "password1", verifyPassword: "not matching", acceptedTermsInput: "on")
        let response = try app.sendRequest(to: path, method: .POST, headers: standardHeaders, body: newUser)

        response.has(statusCode: .internalServerError)
        XCTAssert(response.http.status == .internalServerError, "This should return an error code: \(response.http.status)")
    }
    
    static let allTests = [
        ("testLoginSuccess", testLoginSuccess),
        ("testLoginFail", testLoginFail),
        ("testCreateUserSuccess", testCreateUserSuccess),
        ("testCreateUserExistingEmail", testCreateUserExistingEmail),
        ("testCreateUserPasswordMismatch", testCreateUserPasswordMismatch),
    ]
}
