//
//  TaskResult+testable.swift
//  KognitaCoreTests
//
//  Created by Mats Mollestad on 30/04/2019.
//

import Vapor
import FluentPostgreSQL
import Crypto
@testable import KognitaCore


extension TaskResult {
    static func create(task: Task, session: PracticeSession?, user: User, on conn: PostgreSQLConnection) throws -> TaskResult {

        let score = Double.random(in: -1...1)
        let practiceResult = PracticeSessionResult(result: "", unforgivingScore: score, forgivingScore: (score + 1) / 2, progress: 0)
        let submit = FlashCardTaskSubmit(timeUsed: .random(in: 10...60), knowledge: 0)

        let submitResult = try TaskSubmitResult(submit: submit, result: practiceResult, taskID: task.requireID())

        return try TaskResult(result: submitResult, userID: user.requireID(), session: session)
            .save(on: conn)
            .wait()
    }
}
