//
//  SubjectTests.swift
//  App
//
//  Created by Mats Mollestad on 11/10/2018.
//

@testable import App
import Vapor
import XCTest
import FluentPostgreSQL
import Crypto
@testable import KognitaCore

class SubjectTests: VaporTestCase {
    
    private let subjectPath = "api/subjects"
    
    
    // MARK: - GET /subjects
    
    func testGetAllSubjects() throws {

        let user = try User.create(on: conn)
        _ = try Subject.create(creator: user, on: conn)
        _ = try Subject.create(creator: user, on: conn)

        let startSubjects = try Subject.query(on: conn).all().wait()
        XCTAssert(startSubjects.count != 0, "There is no subjects in the database")

        let response = try app.sendRequest(to: subjectPath, method: .GET, headers: standardHeaders, loggedInUser: user)
        XCTAssert(response.http.status == .ok, "This should not return an error")

        let subjects = try response.content.syncDecode([Subject].self)
        XCTAssert(subjects.count == startSubjects.count, "There should be two subjects, but there were: \(subjects.count)")
    }
    
    
    // MARK: - POST /subjects
    
    func testCreateSubject() throws {

        let user = try User.create(on: conn)

        let requestBody = CreateSubjectRequest(
            name: "OS",
            colorClass: .primary,
            description: "Operativstystemer",
            category: "Tech"
        )

        let response = try app.sendRequest(to: subjectPath, method: .POST, headers: standardHeaders, body: requestBody, loggedInUser: user)
        let subject = try response.content.syncDecode(Subject.self)

        XCTAssert(response.http.status == .ok, "There was an error when posting a new subject: \(response.http.status)")
        XCTAssert(subject.name == requestBody.name, "The saved subject has a different .name")
        XCTAssert(subject.colorClass == requestBody.colorClass, "The saved subject has a different .code")
        XCTAssert(subject.creatorId == user.id, "The creatorId is incorrect: \(subject.creatorId)")

        let currentSubjects = try Subject.query(on: conn).filter(\.name == requestBody.name).all().wait()

        XCTAssert(currentSubjects.isEmpty == false, "The new subject was not added")
    }


    func testCreateSubjectWhenNotLoggedInError() throws {
        let requestBody = CreateSubjectRequest(
            name: "OS",
            colorClass: .primary,
            description: "Operativstystemer",
            category: "Something"
        )

        XCTAssert(try Subject.query(on: conn)
            .filter(\.name == requestBody.name)
            .all()
            .wait()
            .isEmpty == true, "There exists a subject with name: \(requestBody.name)")

        let response = try app.sendRequest(to: subjectPath, method: .POST, headers: standardHeaders, body: requestBody)

        let currentSubjects = try Subject.query(on: conn).filter(\.name == requestBody.name).all().wait()

        XCTAssert(response.http.status == .unauthorized, "Should return an unauthorized error, but returned: \(response.http.status)")
        XCTAssert(currentSubjects.isEmpty == true, "The new subject was added, but should not have been")
    }

    // MARK: - GET /subjects/:id
    
    func testGetSingleSubject() throws {
        let user = try User.create(on: conn)
        let subject = try Subject.create(creator: user, on: conn)
        _ = try Subject.create(creator: user, on: conn)

        let uri = try subjectPath + "/\(subject.requireID())"
        let response = try app.sendRequest(to: uri, method: .GET, headers: standardHeaders, loggedInUser: user)
        XCTAssert(response.http.status == .ok, "This should not return an error")

        let responseSubject = try response.content.syncDecode(Subject.self)
        XCTAssert(responseSubject.name == subject.name, "The response subject name du not match the one retreving, returned \(responseSubject.name)")
        try XCTAssert(responseSubject.requireID() == subject.requireID(), "The response subject id du not match the one retreving, returned \(try! responseSubject.requireID())")
        XCTAssert(responseSubject.category == subject.category, "The response subject category du not match the one retreving, returned \(responseSubject.category)")
    }
    
    
    // MARK: - DELETE /subjects/:id
    
    /// Tests if it is possible to delete a subject
    func testDeleteSubject() throws {

        let user = try User.create(on: conn)

        _ = try Subject.create(creator: user, on: conn)
        let subjectToDelete = try Subject.create(creator: user, on: conn)

        let startSubjects = try Subject.query(on: conn).all().wait()

        let path = try subjectPath + "/\(subjectToDelete.requireID())"
        let response = try app.sendRequest(to: path, method: .DELETE, headers: standardHeaders, loggedInUser: user)
        XCTAssert(response.http.status == .ok, "Not returning an ok status on delete: \(response.http.status)")

        let currentSubjects = try Subject.query(on: conn).all().wait()
        XCTAssert(currentSubjects.count == startSubjects.count - 1, "The amount of subject is incorrect, count: \(currentSubjects.count)")
    }
    
    
    /// Tests if it is possible to delete when not being the creator of a subject
    func testDeleteSubjectWhenNotCreator() throws {
        let user = try User.create(on: conn)
        let creator = try User.create(on: conn)

        let subjectToDelete = try Subject.create(creator: creator, on: conn)

        let startSubjects = try Subject.query(on: conn).all().wait()

        let path = try subjectPath + "/\(subjectToDelete.requireID())"
        let response = try app.sendRequest(to: path, method: .DELETE, headers: standardHeaders, loggedInUser: user)
        XCTAssert(response.http.status == .forbidden, "Not returning a forbidden status on delete: \(response.http.status)")

        let currentSubjects = try Subject.query(on: conn).all().wait()
        XCTAssert(currentSubjects.count == startSubjects.count, "The amount of subject is incorrect, count: \(currentSubjects.count)")
    }
    
    /// Tests if it is possible to delete when not being the creator of a subject
    func testDeleteSubjectWhenNotLoggedIn() throws {
        let creator = try User.create(on: conn)
        let subjectToDelete = try Subject.create(creator: creator, on: conn)

        let startSubjects = try Subject.query(on: conn).all().wait()

        let path = try subjectPath + "/\(subjectToDelete.requireID())"
        let response = try app.sendRequest(to: path, method: .DELETE, headers: standardHeaders)
        XCTAssert(response.http.status == .unauthorized, "Not returning an unauthorized status on delete: \(response.http.status)")

        let currentSubjects = try Subject.query(on: conn).all().wait()
        XCTAssert(currentSubjects.count == startSubjects.count, "The amount of subject is incorrect, count: \(currentSubjects.count)")
    }
    
    
    // MARK: - PUT /subjects/:id
    
//    func testEditSubject() {
//        do {
//            let user = try User.create(on: conn)
//            let subject = try Subject.create(creator: user, on: conn)
//
//            let requestBody = CreateSubject(name: "Kjemi 1", code: "REAK1")
//
//            let uri = try subjectPath + "/\(subject.requireID())"
//            let response = try app.sendRequest(to: uri, method: .PUT, headers: standardHeaders, body: requestBody, loggedInUser: user)
//            let responseSubject = try response.content.syncDecode(Subject.self)
//
//            XCTAssert(response.http.status == .ok, "There was an error when posting a new subject: \(response.http.status)")
//            XCTAssert(requestBody.name == responseSubject.name, "The saved subject has a different .name")
//            XCTAssert(requestBody.code == responseSubject.code, "The saved subject has a different .code")
//
//            let currentSubjects = try Subject.query(on: conn).filter(\.name == requestBody.name).all().wait()
//
//            XCTAssert(currentSubjects.isEmpty == false, "The subject was not updated")
//        } catch let error {
//            XCTFail("Error: \(error)")
//        }
//    }
//
//
//    func testEditSubjectWhenNotCreatorError() {
//        do {
//            let user = try User.create(on: conn)
//            let subject = try Subject.create(on: conn)
//
//            let requestBody = CreateSubject(name: "Kjemi 1", code: "REAK1")
//
//            let uri = try subjectPath + "/\(subject.requireID())"
//            let response = try app.sendRequest(to: uri, method: .PUT, headers: standardHeaders, body: requestBody, loggedInUser: user)
//
//            let databaseSubject = try Subject.find(subject.requireID(), on: conn).wait()
//
//            XCTAssert(response.http.status == .forbidden, "Expexted an forbidden error, but got: \(response.http.status)")
//            XCTAssert(subject.name == databaseSubject?.name, "The saved subject has updated .name")
//            XCTAssert(subject.code == databaseSubject?.code, "The saved subject has updated .code")
//        } catch let error {
//            XCTFail("Error: \(error)")
//        }
//    }
//
//
//    func testEditSubjectWhenNotLoggedInError() {
//        do {
//            let subject = try Subject.create(on: conn)
//
//            let requestBody = CreateSubject(name: "Kjemi 1", code: "REAK1")
//
//            let uri = try subjectPath + "/\(subject.requireID())"
//            let response = try app.sendRequest(to: uri, method: .PUT, headers: standardHeaders, body: requestBody)
//
//            let databaseSubject = try Subject.find(subject.requireID(), on: conn).wait()
//
//            XCTAssert(response.http.status == .unauthorized, "Expexted an unauthorized error, but got: \(response.http.status)")
//            XCTAssert(subject.name == databaseSubject?.name, "The saved subject has updated .name")
//            XCTAssert(subject.code == databaseSubject?.code, "The saved subject has updated .code")
//        } catch let error {
//            XCTFail("Error: \(error)")
//        }
//    }
    
    
//    func testCreateSubjectTest() throws {
//        let duration    = 60 * 3.5
//        let user        = try User.create(on: conn)
//        let subject     = try Subject.create(on: conn)
//        let topicOne    = try Topic.create(subject: subject, on: conn)
//        let topicTwo    = try Topic.create(subject: subject, on: conn)
//        _               = try Task.create(topic: topicOne, on: conn)
//        _               = try Task.create(topic: topicTwo, on: conn)
//        _               = try MultipleChoiseTask.create(topic: topicOne, on: conn)
//        _               = try MultipleChoiseTask.create(topic: topicTwo, on: conn)
//
//        let requestBody = CreateSubjectTest(duration: duration)
//
//        let uri         = try subjectPath + "/\(subject.requireID())/tests"
//        let response    = try app.sendRequest(to: uri, method: .POST, headers: standardHeaders, body: requestBody, loggedInUser: user)
//        XCTAssert(response.http.status == .ok,          "Expexted an ok status, but got: \(response.http.status)")
//
//        let content     = try response.content.syncDecode(SubjectTestContent.self)
//
//        let dbTest      = try SubjectTest.query(on: conn).first().wait()
//        let executions  = try dbTest?.tasks.query(on: conn).all().wait()
//
//        XCTAssert(dbTest != nil,                        "There is no test created")
//        XCTAssert(executions?.count == 3,               "There should be created three taskExecutions, but created \(executions?.count ?? 0)")
//        XCTAssert(content.subject.id == subject.id,     "The subjects is not equal to each other")
//        XCTAssert(content.topics.count == 2,            "Should only return two topics")
//        XCTAssert(content.tasks.count == 3,             "Should only return three tasks")
//    }
//
//
//    func testSubmittAnswerOnTest() throws {
//        let duration    = 60 * 3.5
//        let user        = try User.create(on: conn)
//        let subject     = try Subject.create(on: conn)
//        let topicOne    = try Topic.create(subject: subject, on: conn)
//        let topicTwo    = try Topic.create(subject: subject, on: conn)
//        _               = try MultipleChoiseTask.create(topic: topicOne, on: conn)
//        _               = try MultipleChoiseTask.create(topic: topicTwo, on: conn)
//        _               = try MultipleChoiseTask.create(topic: topicTwo, on: conn)
//
//        let requestBody = CreateSubjectTest(duration: duration)
//
//        let uri         = try subjectPath + "/\(subject.requireID())/tests"
//        let response    = try app.sendRequest(to: uri, method: .POST, headers: standardHeaders, body: requestBody, loggedInUser: user)
//        XCTAssert(response.http.status == .ok,          "Expexted an ok status, but got: \(response.http.status)")
//
//        let content     = try response.content.syncDecode(SubjectTestContent.self)
//
//        let dbTest      = try SubjectTest.query(on: conn).first().wait()
//        let executions  = try dbTest?.tasks.query(on: conn).all().wait()
//
//        XCTAssert(dbTest != nil,                        "There is no test created")
//        XCTAssert(executions?.count == 3,               "There should be created three taskExecutions, but created \(executions?.count ?? 0)")
//        XCTAssert(content.subject.id == subject.id,     "The subjects is not equal to each other")
//        XCTAssert(content.topics.count == 2,            "Should only return two topics")
//        XCTAssert(content.tasks.count == 3,             "Should only return three tasks")
//    }

    
    
    static let allTests = [
        ("testGetAllSubjects", testGetAllSubjects),
//        ("testCreateSubject", testCreateSubject),
        ("testDeleteSubject", testDeleteSubject),
        ("testDeleteSubjectWhenNotCreator", testDeleteSubjectWhenNotCreator),
        ("testDeleteSubjectWhenNotLoggedIn", testDeleteSubjectWhenNotLoggedIn)
    ]
}
