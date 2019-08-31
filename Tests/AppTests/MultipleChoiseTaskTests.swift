//
//  MultipleChoiseTaskTests.swift
//  AppTests
//
//  Created by Mats Mollestad on 10/11/2018.
//

import Vapor
@testable import App
import XCTest
import FluentPostgreSQL
import KognitaCore

class MultipleChoiseTaskTests: VaporTestCase {
    
    
    // GET /subjects/:id/topics/:id/multiple-choises
    
    func testGetAllTasks() throws {
        let user        = try User.create(on: conn)
        let subtopic    = try Subtopic.create(on: conn)
        _               = try MultipleChoiseTask.create(subtopic: subtopic, on: conn)
        _               = try MultipleChoiseTask.create(subtopic: subtopic, on: conn)

        let response    = try app.sendRequest(to: uri, method: .GET, headers: standardHeaders, loggedInUser: user)
        let tasks       = try response.content.syncDecode([MultipleChoiseTask.Data].self)

        XCTAssert(response.http.status  == .ok,     "Expexted a ok response, but got \(response.http.status)")
        XCTAssert(tasks.count           == 2,       "expexted two tasks, but returned \(tasks.count)")
    }
    
    
    func testGetAllTasksNotLoggedInnError() throws {
        let subtopic    = try Subtopic.create(on: conn)
        _               = try MultipleChoiseTask.create(subtopic: subtopic, on: conn)
        _               = try MultipleChoiseTask.create(subtopic: subtopic, on: conn)

        let response    = try app.sendRequest(to: uri, method: .GET, headers: standardHeaders)
        XCTAssert(response.http.status  == .unauthorized,   "Expexted a unauthorized response, but got \(response.http.status)")
    }
    
    func testGetTaskInstanceNotLoggedInnError() throws {
        let subtopic    = try Subtopic.create(on: conn)
        _               = try Task.create(on: conn)
        let task        = try MultipleChoiseTask.create(subtopic: subtopic, on: conn)
        _               = try MultipleChoiseTask.create(subtopic: subtopic, on: conn)

        let uri         = try self.uri + "/\(task.requireID())"
        let response    = try app.sendRequest(to: uri, method: .GET, headers: standardHeaders)

        XCTAssert(response.http.status  == .unauthorized,   "Expexted a unauthorized response, but got \(response.http.status)") 
    }
    
    // DELETE /subjects/:id/topics/:id/multiple-choises/:id
    
    func testDeleteTaskInstance() throws {
        let user                = try User.create(on: conn)
        let subtopic            = try Subtopic.create(on: conn)
        _                       = try Task.create(on: conn)
        let task                = try MultipleChoiseTask.create(subtopic: subtopic, on: conn)
        _                       = try MultipleChoiseTask.create(subtopic: subtopic, on: conn)

        let uri                 = try self.uri + "/\(task.requireID())"
        let response            = try app.sendRequest(to: uri, method: .DELETE, headers: standardHeaders, loggedInUser: user)
        XCTAssert(response.http.status  == .ok,     "Expexted a ok response, but got \(response.http.status)")

        let databaseTask        = try Task.find(task.requireID(), on: conn).wait()
        let databaseMultiple    = try MultipleChoiseTask.find(task.requireID(), on: conn).wait()

        XCTAssert(databaseTask == nil, "The Task instance was not marked as outdated")
        XCTAssert(databaseMultiple != nil, "The MultipleChoiseTask instance was deleted")
    }
    
    func testDeleteTaskInstanceNotLoggedInError() throws {
        let subtopic            = try Subtopic.create(on: conn)
        _                       = try Task.create(on: conn)
        let task                = try MultipleChoiseTask.create(subtopic: subtopic, on: conn)
        _                       = try MultipleChoiseTask.create(subtopic: subtopic, on: conn)

        let uri                 = try self.uri + "/\(task.requireID())"
        let response            = try app.sendRequest(to: uri, method: .DELETE, headers: standardHeaders)
        XCTAssert(response.http.status  == .unauthorized,   "Expexted a unauthorized response, but got \(response.http.status)")
        
        let databaseTask        = try Task.find(task.requireID(), on: conn).wait()
        let databaseMultiple    = try MultipleChoiseTask.find(task.requireID(), on: conn).wait()

        XCTAssert(databaseTask          != nil,             "The Task instance was deleted")
        XCTAssert(databaseMultiple      != nil,             "The MultipleChoiseTask instance was deleted")
    }
    
    var uri: String {
        return "api/tasks/multiple-choise"
    }
    
    static let allTests = [
        ("testGetAllTasks", testGetAllTasks),
        ("testGetAllTasksNotLoggedInnError", testGetAllTasksNotLoggedInnError),
        ("testGetTaskInstanceNotLoggedInnError", testGetTaskInstanceNotLoggedInnError),
        ("testDeleteTaskInstance", testDeleteTaskInstance),
        ("testDeleteTaskInstanceNotLoggedInError", testDeleteTaskInstanceNotLoggedInError)
    ]
}
