//
//  PracticeSessionTests.swift
//  App
//
//  Created by Mats Mollestad on 22/01/2019.
//

import XCTest
@testable import App
@testable import KognitaCore

final class PracticeSessionTests: VaporTestCase {
    
    
    func testToAssignTask() throws {

        let user = try User.create(on: conn)
        let topic = try Topic.create(on: conn)
        let subtopic = try Subtopic.create(on: conn)
        let task1 = try Task.create(subtopic: subtopic, on: conn)
        let task2 = try Task.create(subtopic: subtopic, on: conn)
        
        let session = try PracticeSession.create(
            user,
            subtopics: [subtopic.requireID()],
            numberOfTaskGoal: 2,
            on: conn
        ).wait()

        let id = try session.assignTask(
            in: [topic.requireID()],
            on: conn
        ).wait()
        
        XCTAssert(try task1.requireID() == id || task2.requireID() == id)
    }
    
    static let allTests = [
        ("testToAssignTask", testToAssignTask)
    ]
}
