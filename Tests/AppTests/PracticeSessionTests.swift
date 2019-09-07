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
        let subtopic = try Subtopic.create(on: conn)
        let task1 = try Task.create(subtopic: subtopic, on: conn)
        let task2 = try Task.create(subtopic: subtopic, on: conn)
        
        let session = try PracticeSession.create(
            user,
            subtopics: [subtopic.requireID()],
            numberOfTaskGoal: 2,
            on: conn
        ).wait()

        try session.assignNextTask(on: conn).wait()
        let id = try session.currentTask(on: conn).wait().task.id
        
        XCTAssert(try task1.requireID() == id || task2.requireID() == id)
    }
    
    static let allTests = [
        ("testToAssignTask", testToAssignTask)
    ]
}
