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
        let topic       = try Topic.create(creator: user, on: conn)
        _               = try MultipleChoiseTask.create(topic: topic, on: conn)
        _               = try MultipleChoiseTask.create(topic: topic, on: conn)

        let response    = try app.sendRequest(to: uri, method: .GET, headers: standardHeaders, loggedInUser: user)
        let tasks       = try response.content.syncDecode([MultipleChoiseTaskContent].self)

        XCTAssert(response.http.status  == .ok,     "Expexted a ok response, but got \(response.http.status)")
        XCTAssert(tasks.count           == 2,       "expexted two tasks, but returned \(tasks.count)")
    }
    
    
    func testGetAllTasksNotLoggedInnError() throws {
        let topic       = try Topic.create(on: conn)
        _               = try MultipleChoiseTask.create(topic: topic, on: conn)
        _               = try MultipleChoiseTask.create(topic: topic, on: conn)

        let response    = try app.sendRequest(to: uri, method: .GET, headers: standardHeaders)
        XCTAssert(response.http.status  == .unauthorized,   "Expexted a unauthorized response, but got \(response.http.status)")
    }
    
    
    // POST /subjects/:id/topics/:id/multiple-choises
    
//    func testCreateMultipleChoise() {
//        do {
//            let user        = try User.create(on: conn)
//            let topic       = try Topic.create(creator: user, on: conn)
//            _               = try Task.create(on: conn)
//            let content     = try CreateMultipleChoise(topicId: topic.requireID(),
//                                                       estimatedTime: 60,
//                                                       description: "Some Description",
//                                                       resourceURL: nil,
//                                                       supportedVersion: 1,
//                                                       explenation: nil,
//                                                       question: "Some Question",
//                                                       canSelectMultiple: true)
//
//            let uri         = createURI(for: topic)
//            let response    = try app.sendRequest(to: uri, method: .POST, headers: standardHeaders, body: content, loggedInUser: user)
//            let task        = try response.content.syncDecode(JoinedMultipleChoiseTask.self)
//            let savedTask   = try Task.find(task.taskId, on: conn).wait()
//            let savedMult   = try MultipleChoiseTask.find(task.taskId, on: conn).wait()
//
//
//            XCTAssert(response.http.status          == .ok,                         "Expexted a ok response, but got \(response.http.status)")
//
//            XCTAssert(task.estimatedTime            == content.estimatedTime,       "The estimate time is not equla to the returned. Returns \(task.estimatedTime)")
//            XCTAssert(task.description              == content.description,         "The description is not equla to the returned. Returns \(task.description)")
//            XCTAssert(task.explenation              == content.explenation,         "The explenation is not equla to the returned. Returns \(task.explenation ?? "")")
//            XCTAssert(task.question                 == content.question,            "The question is not equla to the returned. Returns \(task.question)")
//            XCTAssert(task.canSelectMultiple        == content.canSelectMultiple,   "The canSelectMultiple is not equla to the returned. Returns \(task.canSelectMultiple)")
//
//            XCTAssert(savedTask?.estimatedTime      == content.estimatedTime,       "The estimate time is not equla to the returned. Returns \(task.estimatedTime)")
//            XCTAssert(savedTask?.description        == content.description,         "The description is not equla to the returned. Returns \(task.description)")
//            XCTAssert(savedTask?.explenation        == content.explenation,         "The explenation is not equla to the returned. Returns \(task.explenation ?? "")")
//            XCTAssert(savedTask?.question           == content.question,            "The question is not equla to the returned. Returns \(task.question)")
//            XCTAssert(savedMult?.canSelectMultiple  == content.canSelectMultiple,   "The canSelectMultiple is not equla to the returned. Returns \(task.canSelectMultiple)")
//        } catch let error {
//            XCTFail(error.localizedDescription)
//        }
//    }
    
    // GET /subjects/:id/topics/:id/multiple-choises/:id
    
//    func testGetTaskInstance() {
//        do {
//            let user        = try User.create(on: conn)
//            let topic       = try Topic.create(creator: user, on: conn)
//            _               = try Task.create(on: conn)
//            let task        = try MultipleChoiseTask.create(topic: topic, on: conn)
//            _               = try MultipleChoiseTask.create(topic: topic, on: conn)
//
//            let uri         = try createURI(for: topic) + "/\(task.requireID())"
//            let response    = try app.sendRequest(to: uri, method: .GET, headers: standardHeaders, loggedInUser: user)
//            let contentTask = try response.content.syncDecode(JoinedMultipleChoiseTask.self)
//
//            XCTAssert(response.http.status  == .ok,     "Expexted a ok response, but got \(response.http.status)")
//            XCTAssert(contentTask.taskId    == task.id, "Returned the incorrect task, \(contentTask.taskId)")
//        } catch let error {
//            XCTFail(error.localizedDescription)
//        }
//    }
    
    func testGetTaskInstanceNotLoggedInnError() throws {
        let topic       = try Topic.create(on: conn)
        _               = try Task.create(on: conn)
        let task        = try MultipleChoiseTask.create(topic: topic, on: conn)
        _               = try MultipleChoiseTask.create(topic: topic, on: conn)

        let uri         = try self.uri + "/\(task.requireID())"
        let response    = try app.sendRequest(to: uri, method: .GET, headers: standardHeaders)

        XCTAssert(response.http.status  == .unauthorized,   "Expexted a unauthorized response, but got \(response.http.status)")
    }
    
    // DELETE /subjects/:id/topics/:id/multiple-choises/:id
    
    func testDeleteTaskInstance() throws {
        let user                = try User.create(on: conn)
        let topic               = try Topic.create(creator: user, on: conn)
        _                       = try Task.create(on: conn)
        let task                = try MultipleChoiseTask.create(topic: topic, on: conn)
        _                       = try MultipleChoiseTask.create(topic: topic, on: conn)

        let uri                 = try self.uri + "/\(task.requireID())"
        let response            = try app.sendRequest(to: uri, method: .DELETE, headers: standardHeaders, loggedInUser: user)
        XCTAssert(response.http.status  == .ok,     "Expexted a ok response, but got \(response.http.status)")

        let databaseTask        = try Task.find(task.requireID(), on: conn).wait()
        let databaseMultiple    = try MultipleChoiseTask.find(task.requireID(), on: conn).wait()

        XCTAssert(databaseTask?.isOutdated == true, "The Task instance was not marked as outdated")
        XCTAssert(databaseMultiple != nil, "The MultipleChoiseTask instance was deleted")
    }
    
//    func testDeleteTaskInstanceNotCreatorError() throws {
//
//        let user                = try User.create(on: conn)
//        let topic               = try Topic.create(on: conn)
//        _                       = try Task.create(on: conn)
//        let task                = try MultipleChoiseTask.create(topic: topic, on: conn)
//        _                       = try MultipleChoiseTask.create(topic: topic, on: conn)
//
//        let uri                 = try self.uri + "/\(task.requireID())"
//        let response            = try app.sendRequest(to: uri, method: .DELETE, headers: standardHeaders, loggedInUser: user)
//        XCTAssert(response.http.status  == .forbidden,  "Expexted a forbidden response, but got \(response.http.status)")
//
//        let databaseTask        = try Task.find(task.requireID(), on: conn).wait()
//        let databaseMultiple    = try MultipleChoiseTask.find(task.requireID(), on: conn).wait()
//
//        XCTAssert(databaseTask          != nil,         "The Task instance was deleted")
//        XCTAssert(databaseMultiple      != nil,         "The MultipleChoiseTask instance was deleted")
//    }
    
    func testDeleteTaskInstanceNotLoggedInError() throws {
        let topic               = try Topic.create(on: conn)
        _                       = try Task.create(on: conn)
        let task                = try MultipleChoiseTask.create(topic: topic, on: conn)
        _                       = try MultipleChoiseTask.create(topic: topic, on: conn)

        let uri                 = try self.uri + "/\(task.requireID())"
        let response            = try app.sendRequest(to: uri, method: .DELETE, headers: standardHeaders)
        XCTAssert(response.http.status  == .unauthorized,   "Expexted a unauthorized response, but got \(response.http.status)")
        
        let databaseTask        = try Task.find(task.requireID(), on: conn).wait()
        let databaseMultiple    = try MultipleChoiseTask.find(task.requireID(), on: conn).wait()

        XCTAssert(databaseTask          != nil,             "The Task instance was deleted")
        XCTAssert(databaseMultiple      != nil,             "The MultipleChoiseTask instance was deleted")
    }
    
    
    // PUT /subjects/:id/topics/:id/multiple-choises/:id
    
//    func testUpdateTaskInstance() {
//        do {
//            let user            = try User.create(on: conn)
//            let topic           = try Topic.create(creator: user, on: conn)
//            let task            = try MultipleChoiseTask.create(topic: topic, on: conn)
//
//            let content         = try CreateMultipleChoise(topicId: topic.requireID(),
//                                                               estimatedTime: 10,
//                                                               description: "Some New Description",
//                                                               resourceURL: nil,
//                                                               supportedVersion: 1,
//                                                               explenation: "Some new explenation",
//                                                               question: "Some new Question",
//                                                               canSelectMultiple: false)
//
//
//            let uri             = try createURI(for: topic) + "/\(task.requireID())"
//            let response        = try app.sendRequest(to: uri, method: .PUT, headers: standardHeaders, body: content, loggedInUser: user)
//
//            let savedTask       = try Task.find(task.requireID(), on: conn).wait()
//            let savedMultiple   = try MultipleChoiseTask.find(task.requireID(), on: conn).wait()
//
//            XCTAssert(response.http.status              == .ok,                         "Expexted a ok response, but got \(response.http.status)")
//
//            XCTAssert(savedTask?.estimatedTime          == content.estimatedTime,       "The estimate time is not equla to the returned. Returns \(savedTask?.estimatedTime ?? 0)")
//            XCTAssert(savedTask?.description            == content.description,         "The description is not equla to the returned. Returns \(savedTask?.description ?? "")")
//            XCTAssert(savedTask?.explenation            == content.explenation,         "The explenation is not equla to the returned. Returns \(savedTask?.explenation ?? "")")
//            XCTAssert(savedTask?.question               == content.question,            "The question is not equla to the returned. Returns \(savedTask?.question ?? "")")
//            XCTAssert(savedMultiple?.canSelectMultiple  == content.canSelectMultiple,   "The canSelectMultiple is not equla to the returned. Returns \(savedMultiple?.canSelectMultiple ?? false)")
//        } catch let error {
//            XCTFail(error.localizedDescription)
//        }
//    }
//
//    func testUpdateTaskInstanceNotCreatorError() {
//        do {
//            let user            = try User.create(on: conn)
//            let topic           = try Topic.create(on: conn)
//            let multiple        = try MultipleChoiseTask.create(topic: topic, on: conn)
//            guard let task      = try multiple.task?.get(on: conn).wait() else { throw Errors.badTest }
//
//            let content         = try CreateMultipleChoise(topicId: topic.requireID(),
//                                                           estimatedTime: 10,
//                                                           description: "Some New Description",
//                                                           resourceURL: nil,
//                                                           supportedVersion: 1,
//                                                           explenation: "Some new explenation",
//                                                           question: "Some new Question",
//                                                           canSelectMultiple: false)
//
//
//            let uri             = try createURI(for: topic) + "/\(task.requireID())"
//            let response        = try app.sendRequest(to: uri, method: .PUT, headers: standardHeaders, body: content, loggedInUser: user)
//
//            let savedTask       = try Task.find(task.requireID(), on: conn).wait()
//            let savedMultiple   = try MultipleChoiseTask.find(task.requireID(), on: conn).wait()
//
//            XCTAssert(response.http.status              == .forbidden,                  "Expexted a forbidden response, but got \(response.http.status)")
//            XCTAssert(savedTask?.estimatedTime          == task.estimatedTime,          "The estimate time is not equla to the returned. Returns \(savedTask?.estimatedTime ?? 0)")
//            XCTAssert(savedTask?.description            == task.description,            "The description is not equla to the returned. Returns \(savedTask?.description ?? "")")
//            XCTAssert(savedTask?.explenation            == task.explenation,            "The explenation is not equla to the returned. Returns \(savedTask?.explenation ?? "")")
//            XCTAssert(savedTask?.question               == task.question,               "The question is not equla to the returned. Returns \(savedTask?.question ?? "")")
//            XCTAssert(savedMultiple?.canSelectMultiple  == multiple.canSelectMultiple,  "The canSelectMultiple is not equla to the returned. Returns \(savedMultiple?.canSelectMultiple ?? false)")
//        } catch let error {
//            XCTFail(error.localizedDescription)
//        }
//    }
    
    
//    func testUpdateTaskInstanceNotLoggedInError() {
//        do {
//            let topic           = try Topic.create(on: conn)
//            let multiple        = try MultipleChoiseTask.create(topic: topic, on: conn)
//            guard let task      = try multiple.task?.get(on: conn).wait() else { throw Errors.badTest }
//            
//            let content         = try CreateMultipleChoise(topicId: topic.requireID(),
//                                                           estimatedTime: 10,
//                                                           description: "Some New Description",
//                                                           resourceURL: nil,
//                                                           supportedVersion: 1,
//                                                           explenation: "Some new explenation",
//                                                           question: "Some new Question",
//                                                           canSelectMultiple: false)
//            
//            
//            let uri             = try createURI(for: topic) + "/\(task.requireID())"
//            let response        = try app.sendRequest(to: uri, method: .PUT, headers: standardHeaders, body: content)
//            
//            let savedTask       = try Task.find(task.requireID(), on: conn).wait()
//            let savedMultiple   = try MultipleChoiseTask.find(task.requireID(), on: conn).wait()
//            
//            XCTAssert(response.http.status              == .unauthorized,               "Expexted a unauthorized response, but got \(response.http.status)")
//            XCTAssert(savedTask?.estimatedTime          == task.estimatedTime,          "The estimate time is not equla to the returned. Returns \(savedTask?.estimatedTime ?? 0)")
//            XCTAssert(savedTask?.description            == task.description,            "The description is not equla to the returned. Returns \(savedTask?.description ?? "")")
//            XCTAssert(savedTask?.explenation            == task.explenation,            "The explenation is not equla to the returned. Returns \(savedTask?.explenation ?? "")")
//            XCTAssert(savedTask?.question               == task.question,               "The question is not equla to the returned. Returns \(savedTask?.question ?? "")")
//            XCTAssert(savedMultiple?.canSelectMultiple  == multiple.canSelectMultiple,  "The canSelectMultiple is not equla to the returned. Returns \(savedMultiple?.canSelectMultiple ?? false)")
//        } catch let error {
//            XCTFail(error.localizedDescription)
//        }
//    }
    
    
    var uri: String {
        return "api/tasks/multiple-choise"
    }
}
