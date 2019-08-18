//
//  SubjectTestTaskExecution.swift
//  App
//
//  Created by Mats Mollestad on 15/11/2018.
//

import FluentPostgreSQL
import Vapor
import KognitaCore

protocol TaskMapping {
    var subjectTestID: SubjectTest.ID { get }
    var startTime: Date? { get set }
    var endTime: Date? { get set }
}

protocol SubjectTaskTestable {
    func assign(to test: SubjectTestSet, topic: Topic, on conn: DatabaseConnectable) throws -> Future<Void>
}

final class SubjectTestTaskExecution: PostgreSQLPivot {

    typealias Left                      = SubjectTest
    static var leftIDKey: LeftIDKey     = \.subjectTestID

    typealias Right                     = Task
    static var rightIDKey: RightIDKey   = \.taskID

    var id: Int?
    var subjectTestID: SubjectTest.ID
    var taskID: Task.ID

    var startTime: Date?
    var endTime: Date?

    init(subjectTest: SubjectTest, taskID: Task.ID) throws {
        subjectTestID   = try subjectTest.requireID()
        self.taskID     = taskID
    }
}

extension SubjectTestTaskExecution: Migration {
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        return PostgreSQLDatabase.create(SubjectTestTaskExecution.self, on: conn) { builder in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.subjectTestID)
            builder.field(for: \.taskID)
            builder.field(for: \.startTime)
            builder.field(for: \.endTime)

            builder.reference(from: \.subjectTestID, to: \SubjectTest.id)
            builder.reference(from: \.taskID, to: \Task.id)

            builder.unique(on: \.subjectTestID, \.taskID)
        }
    }

    static func revert(on connection: PostgreSQLConnection) -> Future<Void> {
        return PostgreSQLDatabase.delete(SubjectTestTaskExecution.self, on: connection)
    }
}

struct SubjectTestTask: Content {
    /// The url t
    let getTaskUrl: URL
    let submitAnswerURL: URL
}
