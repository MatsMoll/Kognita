/// Copyright (c) 2018 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import Vapor
@testable import App
import Authentication
import FluentPostgreSQL
import KognitaCore

extension Application {
    
    static func testable(envArgs: [String]? = nil) throws -> Application {
        var config = Config.default()
        var services = Services.default()
        var env = Environment.testing
        
        if let environmentArgs = envArgs {
            env.arguments = environmentArgs
        }
        
        try App.configure(&config, &env, &services)
        let app = try Application(config: config, environment: env, services: services)
        
        try App.boot(app)
        return app
    }
    
    static func reset() throws {
        try Application.testable(envArgs: ["vapor", "revert", "--all", "-y"]).asyncRun().wait()
        try Application.testable(envArgs: ["vapor", "migrate", "-y"]).asyncRun().wait()
    }
    
    func sendRequest<T>(to path: String, method: HTTPMethod, headers: HTTPHeaders = .init(), body: T? = nil, loggedInUser: User? = nil) throws -> Response where T: Content {
        
        var headers = headers
        
        if let loggedInUser = loggedInUser {
            var tokenHeaders = HTTPHeaders()
            let credentials = BasicAuthorization(username: loggedInUser.email, password: "password")
            tokenHeaders.basicAuthorization = credentials
            
            let tokenResponse = try self.sendRequest(to: "/api/users/login", method: HTTPMethod.POST, headers: tokenHeaders)
            let token = try tokenResponse.content.syncDecode(User.Login.Token.self)
            headers.add(name: .authorization, value: "Bearer \(token.bearerToken)")
        }
        
        let responder = try self.make(Responder.self)
        let request = HTTPRequest(method: method, url: URL(string: path)!, headers: headers)
        let wrappedRequest = Request(http: request, using: self)
        
        if let body = body {
            try wrappedRequest.content.encode(body)
        }
        
        return try responder.respond(to: wrappedRequest).wait()
    }
    
    
    /// A simpler version that do not take any body parameter
    func sendRequest(to path: String, method: HTTPMethod, headers: HTTPHeaders = .init(), loggedInUser: User? = nil) throws -> Response {
        let bodyContent: EmptyContent? = nil
        return try sendRequest(to: path, method: method, headers: headers, body: bodyContent, loggedInUser: loggedInUser)
    }
    
    /// A simpler version that decodes the response to a given type
    func sendRequest<C, T>(to path: String, method: HTTPMethod, headers: HTTPHeaders = .init(), body: C? = nil, loggedInUser: User? = nil, decodeTo: T.Type) throws -> T where T: Content, C: Content {
        return try self.sendRequest(to: path, method: method, headers: headers, body: body, loggedInUser: loggedInUser).content.syncDecode(decodeTo)
    }
    
}

struct EmptyContent: Content {}
