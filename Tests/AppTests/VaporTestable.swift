//
//  VaporTestable.swift
//  App
//
//  Created by Mats Mollestad on 08/11/2018.
//

import Vapor
@testable import App
import XCTest
import FluentPostgreSQL


/// A class that setups a application in a testable enviroment and creates a connection to the database
class VaporTestCase: XCTestCase {
    
    enum Errors: Error {
        case badTest
    }
    
    lazy var app: Application = try! Application.testable(envArgs: self.envArgs)
    var conn: PostgreSQLConnection!
    
    let standardHeaders: HTTPHeaders = ["Content-Type" : "application/json"]
    
    var envArgs: [String]?
    
    
    override func setUp() {
        super.setUp()
        print("Running setup")
        try! Application.reset()
        app = try! Application.testable()
        conn = try! app.newConnection(to: .psql).wait()
    }
    
    override func tearDown() {
        super.tearDown()
        app.shutdownGracefully { (error) in
            guard let error = error else { return }
            print("Error shuttingdown: \(error)")
        }
        conn.close()
    }
}


extension Response {
    func has(statusCode: HTTPResponseStatus) {
        XCTAssertEqual(self.http.status, statusCode)
    }

    func has(headerName: String, with value: String? = nil) {
        XCTAssertTrue(self.http.headers.contains(name: headerName))
//        XCTAssertTrue(self.http.headers.firstValue(name: headerName) == value)
    }
}
