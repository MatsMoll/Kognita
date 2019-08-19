//
//  TopicTests.swift
//  AppTests
//
//  Created by Mats Mollestad on 11/10/2018.
//

@testable import App
import XCTest
import Vapor
import FluentPostgreSQL
import KognitaCore


class TopicTests: VaporTestCase {
    
    private let path = "api/topics/"

    
    func testGetAllTopics() throws {

        let user                = try User.create(on: conn)
        let topic               = try Topic.create(on: conn)
        _                       = try Topic.create(chapter: 2, creatorId: topic.creatorId, subjectId: topic.subjectId, on: conn)
        let otherTopic          = try Topic.create(on: conn)

        let uri                 = "api/subjects/\(topic.subjectId)/topics"
        let response            = try app.sendRequest(to: uri, method: .GET, headers: standardHeaders, loggedInUser: user)

        let topics              = try response.content.syncDecode([Topic].self)
        XCTAssert(response.http.status      == .ok,         "The http status code should have been OK, but were \(response.http.status)")

        let isMatchingSubject   = topics.contains(where: { $0.id == otherTopic.id })

        XCTAssert(topics.count              == 2,           "Should return two topics for subject \(topic.subjectId), but returned \(topics.count)")
        XCTAssert(isMatchingSubject         == false,       "The response contains a topic that should not be there")
    }
    
    
    func testGetTopicsWhenNotLoggedInError() throws {

        let topic       = try Topic.create(on: conn)
        _               = try Topic.create(chapter: 2, creatorId: topic.creatorId, subjectId: topic.subjectId, on: conn)
        _               = try Topic.create(on: conn)

        let response    = try app.sendRequest(to: path, method: .GET, headers: standardHeaders)
        XCTAssert(response.http.status == .unauthorized, "The http statuscode should have been unauthorized, but were \(response.http.status)")

        if let topics = try? response.content.syncDecode([Topic].self) {
            XCTAssert(topics.count == 0, "Should not return any topics, but returned \(topics.count)")
        }
    }
    
    
    
    // MARK: - POST /subjects/:id/topics
    
//    func testCreateTopicInSubject() {
//        do {
//            let user            = try User.create(on: conn)
//            let subject         = try Subject.create(creator: user, on: conn)
//
//            let topicContent    = CreateTopicAPI(name: "Test", chapter: 1, preTopicId: nil)
//
//            let uri             = try path + "\(subject.requireID())/topics"
//            let response        = try app.sendRequest(to: uri, method: .POST, headers: standardHeaders, body: topicContent, loggedInUser: user)
//
//            let topic           = try response.content.syncDecode(Topic.self)
//            let databaseTopic   = try Topic.find(topic.requireID(), on: conn).wait()
//
//            XCTAssert(response.http.status  == .ok,                         "The http statuscode should have been ok, but were \(response.http.status)")
//            XCTAssert(topic.name            == topicContent.name,           "The topic has a different value then the submitted. \(topic.name)")
//            XCTAssert(topic.preTopicId      == topicContent.preTopicId,     "The topic has a different value then the submitted. \(topic.preTopicId ?? 0)")
//            XCTAssert(topic.subjectId       == subject.id,                  "The subject id is incorrect. Were \(topic.subjectId)")
//            XCTAssert(topic.name            == databaseTopic?.name,         "Topic is not in database")
//        } catch let error {
//            XCTFail("ERROR: \(error)")
//        }
//    }
//
//
//    func testCreateTopicInSubjectWhenNotCreatorError() {
//        do {
//            let user            = try User.create(on: conn)
//            let subject         = try Subject.create(on: conn)
//            let topicContent    = CreateTopicAPI(name: "Test", chapter: 1, preTopicId: nil)
//
//            let uri             = try path + "\(subject.requireID())/topics"
//            let response        = try app.sendRequest(to: uri, method: .POST, headers: standardHeaders, body: topicContent, loggedInUser: user)
//
//            let databaseTopic   = try Topic.query(on: conn).filter(\.name == topicContent.name).all().wait()
//
//            XCTAssert(response.http.status      == .forbidden,      "The http statuscode should have been forbidden, but were \(response.http.status)")
//            XCTAssert(databaseTopic.isEmpty     == true,            "Topic was saved in database, but should not have been saved")
//        } catch let error {
//            XCTFail("ERROR: \(error)")
//        }
//    }
//
//
//    func testCreateTopicInSubjectWhenNotLoggedIn() {
//        do {
//            let subject         = try Subject.create(on: conn)
//            let topicContent    = CreateTopicAPI(name: "Test", chapter: 1, preTopicId: nil)
//
//            let uri             = try path + "\(subject.requireID())/topics"
//            let response        = try app.sendRequest(to: uri, method: .POST, headers: standardHeaders, body: topicContent)
//
//            let databaseTopic   = try Topic.query(on: conn).filter(\.name == topicContent.name).all().wait()
//
//            XCTAssert(response.http.status      == .unauthorized,   "The http statuscode should have been unauthorized, but were \(response.http.status)")
//            XCTAssert(databaseTopic.isEmpty     == true,            "Topic was saved in database, but should not have been saved")
//        } catch let error {
//            XCTFail("ERROR: \(error)")
//        }
//    }
    
    
    
    // MARK: - GET /subjects/:id/topics/:id
    
    func testGetSubjectWithId() throws {

        let user            = try User.create(on: conn)
        let topic           = try Topic.create(on: conn)
        _                   = try Topic.create(chapter: 2, creatorId: topic.creatorId, subjectId: topic.subjectId, on: conn)

        let uri             = try path + "\(topic.requireID())"
        let response        = try app.sendRequest(to: uri, method: .GET, headers: standardHeaders, loggedInUser: user)
        XCTAssert(response.http.status          == .ok,                 "The http statuscode should have been OK, but were \(response.http.status)")

        let responseTopic   = try response.content.syncDecode(Topic.self)

        try XCTAssert(responseTopic.requireID() == topic.requireID(),   "The ids do not match, returned topic with id: \(try! responseTopic.requireID())")
        XCTAssert(responseTopic.name            == topic.name,          "The names do not match, returned topic with id: \(responseTopic.name)")
        XCTAssert(responseTopic.preTopicId      == topic.preTopicId,    "The preTopicIds do not match, returned topic with id: \(responseTopic.preTopicId ?? 0)")
        XCTAssert(responseTopic.subjectId       == topic.subjectId,     "The subjectIds do not match, returned topic with id: \(responseTopic.subjectId)")
    }
    
    
    func testGetSubjectWithIdWhenNotLoggedInError() throws {

        let topic           = try Topic.create(on: conn)
        _                   = try Topic.create(chapter: 2, creatorId: topic.creatorId, subjectId: topic.subjectId, on: conn)

        let uri             = try path + "\(topic.requireID())"
        let response        = try app.sendRequest(to: uri, method: .GET, headers: standardHeaders)

        XCTAssert(response.http.status == .unauthorized, "The http statuscode should have been unauthorized, but were \(response.http.status)")
    }
    
    
    // MARK: - DELETE /subjects/:id/topics/:id
    
    func testDeleteingTopic() throws {
        let user            = try User.create(on: conn)
        let topic           = try Topic.create(creator: user, on: conn)
        _                   = try Topic.create(chapter: 2, creatorId: topic.creatorId, subjectId: topic.subjectId, on: conn)

        let uri             = try path + "\(topic.requireID())"
        let response        = try app.sendRequest(to: uri, method: .DELETE, headers: standardHeaders, loggedInUser: user)
        XCTAssert(response.http.status  == .ok, "The http statuscode should have been ok, but were \(response.http.status)")

        let databaseTopic   = try Topic.find(topic.requireID(), on: conn).wait()
        XCTAssert(databaseTopic         == nil, "The topic should be deleted, but still exists in the database")
    }
    
//    func testDeleteingTopicWhenNotCreatorError() throws {
//        let user            = try User.create(on: conn)
//        let topic           = try Topic.create(on: conn)
//        _                   = try Topic.create(chapter: 2, creatorId: topic.creatorId, subjectId: topic.subjectId, on: conn)
//
//        let uri             = try path + "\(topic.requireID())"
//        let response        = try app.sendRequest(to: uri, method: .DELETE, headers: standardHeaders, loggedInUser: user)
//        XCTAssert(response.http.status  == .forbidden, "The http statuscode should have been forbidden, but were \(response.http.status)")
//
//        let databaseTopic   = try Topic.find(topic.requireID(), on: conn).wait()
//        XCTAssert(databaseTopic         != nil, "The topic should NOT be deleted, but the topic is not in the database")
//    }
    
    func testDeleteingTopicWhenNotLoggedInError() throws {
        let topic           = try Topic.create(on: conn)
        _                   = try Topic.create(chapter: 2, creatorId: topic.creatorId, subjectId: topic.subjectId, on: conn)

        let uri             = try path + "\(topic.requireID())"
        let response        = try app.sendRequest(to: uri, method: .DELETE, headers: standardHeaders)
        XCTAssert(response.http.status  == .unauthorized,   "The http statuscode should have been unauthorized, but were \(response.http.status)")

        let databaseTopic   = try Topic.find(topic.requireID(), on: conn).wait()
        XCTAssert(databaseTopic         != nil,             "The topic should NOT be deleted, but the topic is not in the database")
    }
    
    
    // MARK: - PUT /subjects/:id/topics/:id
    
//    func testEditTopic() {
//        do {
//            let user            = try User.create(on: conn)
//            let subject         = try Subject.create(creator: user, on: conn)
//            let preTopic        = try Topic.create(creatorId: subject.creatorId, subjectId: subject.requireID(), on: conn)
//            let topicToModify   = try Topic.create(chapter: 2, creatorId: subject.creatorId, subjectId: subject.requireID(), on: conn)
//
//            let topicContent    = try CreateTopicAPI(name: "Modified Topic", chapter: 3, preTopicId: preTopic.requireID())
//
//            let uri             = try path + "\(subject.requireID())/topics/\(topicToModify.requireID())"
//            let response        = try app.sendRequest(to: uri, method: .PUT, headers: standardHeaders, body: topicContent, loggedInUser: user)
//
//            let databaseTopic   = try Topic.find(topicToModify.requireID(), on: conn).wait()
//
//            XCTAssert(response.http.status      == .ok,                     "The http statuscode should have been ok, but were \(response.http.status)")
//            XCTAssert(databaseTopic?.name       == topicContent.name,       "Topic was not updated in the database")
//            XCTAssert(databaseTopic?.preTopicId == topicContent.preTopicId, "Topic was not updated in the database")
//            XCTAssert(databaseTopic?.chapter    == topicContent.chapter,    "Topic was not updated in the database")
//        } catch let error {
//            XCTFail("ERROR: \(error)")
//        }
//    }
//
//
//    func testEditTopicWhenNotCreatorError() {
//        do {
//            let user            = try User.create(on: conn)
//            let subject         = try Subject.create(on: conn)
//            let preTopic        = try Topic.create(creatorId: subject.creatorId, subjectId: subject.requireID(), on: conn)
//            let topicToModify   = try Topic.create(chapter: 2, creatorId: subject.creatorId, subjectId: subject.requireID(), on: conn)
//
//            let topicContent    = try CreateTopicAPI(name: "Modified Topic", chapter: 3, preTopicId: preTopic.requireID())
//
//            let uri             = try path + "\(subject.requireID())/topics/\(topicToModify.requireID())"
//            let response        = try app.sendRequest(to: uri, method: .PUT, headers: standardHeaders, body: topicContent, loggedInUser: user)
//
//            let databaseTopic   = try Topic.find(topicToModify.requireID(), on: conn).wait()
//
//            XCTAssert(response.http.status      == .forbidden,              "The http statuscode should have been forbidden, but were \(response.http.status)")
//            XCTAssert(databaseTopic?.name       != topicContent.name,       "Topic was updated in the database")
//            XCTAssert(databaseTopic?.preTopicId != topicContent.preTopicId, "Topic was updated in the database")
//            XCTAssert(databaseTopic?.chapter    != topicContent.chapter,    "Topic was updated in the database")
//        } catch let error {
//            XCTFail("ERROR: \(error)")
//        }
//    }
//
//    func testEditTopicWhenNotLoggedInError() {
//        do {
//            let subject         = try Subject.create(on: conn)
//            let preTopic        = try Topic.create(creatorId: subject.creatorId, subjectId: subject.requireID(), on: conn)
//            let topicToModify   = try Topic.create(chapter: 2, creatorId: subject.creatorId, subjectId: subject.requireID(), on: conn)
//
//            let topicContent    = try CreateTopicAPI(name: "Modified Topic", chapter: 3, preTopicId: preTopic.requireID())
//
//            let uri             = try path + "\(subject.requireID())/topics/\(topicToModify.requireID())"
//            let response        = try app.sendRequest(to: uri, method: .PUT, headers: standardHeaders, body: topicContent)
//
//            let databaseTopic   = try Topic.find(topicToModify.requireID(), on: conn).wait()
//
//            XCTAssert(response.http.status      == .unauthorized,           "The http statuscode should have been forbidden, but were \(response.http.status)")
//            XCTAssert(databaseTopic?.name       != topicContent.name,       "Topic was updated in the database")
//            XCTAssert(databaseTopic?.preTopicId != topicContent.preTopicId, "Topic was updated in the database")
//            XCTAssert(databaseTopic?.chapter    != topicContent.chapter,    "Topic was updated in the database")
//        } catch let error {
//            XCTFail("ERROR: \(error)")
//        }
//    }
}
