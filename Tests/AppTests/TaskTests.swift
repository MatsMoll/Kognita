//
//  TaskTests.swift
//  App
//
//  Created by Mats Mollestad on 09/11/2018.
//

import Vapor
@testable import App
import XCTest
import FluentPostgreSQL
import KognitaCore

//class TaskTests: VaporTestCase {
//
//    func testGetAllTasks() {
//        do {
//            let user        = try User.create(on: conn)
//            let topic       = try Topic.create(creator: user, on: conn)
//            let task        = try Task.create(topic: topic, on: conn)
//            _               = try Task.create(creatorId: task.creatorId, topicId: task.topicId, on: conn)
//            _               = try MultipleChoiseTask.create(topic: topic, on: conn)
//
//            let uri         = try createURI(for: topic)
//            let response    = try app.sendRequest(to: uri, method: .GET, headers: standardHeaders, loggedInUser: user)
//            XCTAssert(response.http.status  == .ok,     "Expexted a ok response, but got \(response.http.status)")
//
//            let tasks = try response.content.syncDecode([Task].self)
//            XCTAssert(tasks.count == 3,       "expexted two tasks, but returned \(tasks.count)")
//        } catch let error {
//            XCTFail(error.localizedDescription)
//        }
//    }
//
//
//    func testGetAllTasksNotLoggedInnError() {
//        do {
//            let topic       = try Topic.create(on: conn)
//            let task        = try Task.create(topic: topic, on: conn)
//            _               = try Task.create(creatorId: task.creatorId, topicId: task.topicId, on: conn)
//
//            let uri         = try createURI(for: topic)
//            let response    = try app.sendRequest(to: uri, method: .GET, headers: standardHeaders)
//
//            XCTAssert(response.http.status  == .unauthorized,   "Expexted a unauthorized response, but got \(response.http.status)")
//        } catch let error {
//            XCTFail(error.localizedDescription)
//        }
//    }
//
//
//    func createURI(for topic: Topic) throws -> String {
//        return try "api/subjects/\(topic.subjectId)/topics/\(topic.requireID())/tasks"
//    }
//}
