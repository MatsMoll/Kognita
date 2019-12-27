import XCTest
@testable import App
import Vapor
import FluentPostgreSQL
@testable import KognitaCore
import KognitaCoreTestable

class UserTests: VaporTestCase {
    
    private let uri = "api/users"
    
    
    func testLoginSuccess() throws {

        let user = try User.create(email: "test@1.com", on: conn)

        var headers = standardHeaders
        headers.add(name: .authorization, value: "Basic dGVzdEAxLmNvbTpwYXNzd29yZA==")
        let response = try app.sendRequest(to: uri + "/login", method: .POST, headers: headers)
        XCTAssert(response.http.status == .ok, "This should not return an error")

        let token = try response.content.syncDecode(UserToken.self)
        XCTAssert(token.userID == user.id, "The user id is not equal to the logged in user")
    }
    
    func testLoginFail() throws {

        _ = try User.create(on: conn)

        var headers = standardHeaders
        headers.add(name: .authorization, value: "Basic dGVzdEAxLmNvbTpwYXNzd29y")
        let response = try app.sendRequest(to: uri + "/login", method: .POST, headers: headers)

        XCTAssert(response.http.status == .unauthorized, "This should not return an error")
    }
    
    
    func testCreateUserSuccess() throws {

        _ = try User.create(on: conn)

        let newUser = User.Create.Data(username: "Mats", email: "test@3.com", password: "password", verifyPassword: "password", acceptedTermsInput: "on")
        let response = try app.sendRequest(to: uri, method: .POST, headers: standardHeaders, body: newUser)
        XCTAssert(response.http.status == .ok, "This should not return an error code: \(response.http.status)")

        let user = try response.content.syncDecode(User.Create.Response.self)
        XCTAssert(user.username == newUser.username, "The name is different: \(user.username)")
        XCTAssert(user.email == newUser.email, "The email is different: \(user.email)")
    }
    
    func testCreateUserExistingEmail() throws {

        let user = try User.create(on: conn)
        let newUser = User.Create.Data(username: "Mats", email: user.email, password: "password", verifyPassword: "password", acceptedTermsInput: "on")
        let response = try app.sendRequest(to: uri, method: .POST, headers: standardHeaders, body: newUser)
        XCTAssert(response.http.status == .internalServerError, "This should return an error code, returned: \(response.http.status)")
    }
    
    func testCreateUserPasswordMismatch() throws {
        let newUser = User.Create.Data(username: "Mats", email: "test@3.com", password: "password1", verifyPassword: "not matching", acceptedTermsInput: "on")
        let response = try app.sendRequest(to: uri, method: .POST, headers: standardHeaders, body: newUser)

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
