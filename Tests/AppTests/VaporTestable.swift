//
//  VaporTestable.swift
//  App
//
//  Created by Mats Mollestad on 08/11/2018.
//
// swiftlint:disable force_try

import Vapor
@testable import App
import XCTest
import FluentSQL
import XCTVapor

/// A class that setups a application in a testable enviroment and creates a connection to the database
class VaporTestCase: XCTestCase {

    enum Errors: Error {
        case badTest
    }

    var app: Application!

    let standardHeaders: HTTPHeaders = ["Content-Type": "application/json"]

    var envArgs: [String]?

    override func setUp() {
        super.setUp()
        app = try! Application.testable()
        self.resetDB()
    }

    func resetDB() {
        guard let database = app.databases.database(logger: app.logger, on: app.eventLoopGroup.next()) as? SQLDatabase else { fatalError() }
        try! database.raw("DROP SCHEMA public CASCADE").run().wait()
        try! database.raw("CREATE SCHEMA public").run().wait()
        try! database.raw("GRANT ALL ON SCHEMA public TO public").run().wait()
        try! app.autoMigrate().wait()
    }

    override func tearDown() {
        super.tearDown()
        app.shutdown()
        app = nil
    }

    func failableTest(line: UInt = #line, file: StaticString = #file, test: (() throws -> Void)) {
        do {
            try test()
        } catch {
            XCTFail(error.localizedDescription, file: file, line: line)
        }
    }

    func throwsError<T: Error>(of type: T.Type, line: UInt = #line, file: StaticString = #file, test: () throws -> Void) {
        do {
            try test()
            XCTFail("Did not throw an error", file: file, line: line)
        } catch let error {
            switch error {
            case is T: return
            default: XCTFail(error.localizedDescription, file: file, line: line)
            }
        }
    }
}

extension XCTHTTPResponse {
    func has(statusCode: HTTPResponseStatus, file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(status, statusCode, "The http status code should have been \(statusCode), but were \(status)", file: file, line: line)
    }

    func has(headerName: String, with value: String? = nil, file: StaticString = #file, line: UInt = #line) {
        XCTAssertTrue(self.headers.contains(name: headerName), file: file, line: line)
    }

    func has<T: Decodable>(content type: T.Type, file: StaticString = #file, line: UInt = #line) {
        XCTAssertNoThrow(
            try content.decode(T.self),
            "Was not able to decode \(type) based on the reponse content",
            file: file,
            line: line
        )
    }
}
