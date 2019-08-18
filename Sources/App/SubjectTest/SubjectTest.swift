//
//  SubjectTest.swift
//  App
//
//  Created by Mats Mollestad on 15/11/2018.
//

import FluentPostgreSQL
import Vapor
import KognitaCore

typealias SubjectTestCreateContent = (test: SubjectTest, tasks: [(topic: Topic, task: SubjectTaskTestable)])

final class SubjectTest: PostgreSQLModel {

    var id: Int?

    var subjectId: Subject.ID
    var creatorId: User.ID

    var startTime: Date?
    var endTime: Date?

    var isCompleted: Bool {
        return endTime != nil
    }

    public static var createdAtKey: TimestampKey? = \.startTime

    init(user: User, subject: Subject) throws {
        self.creatorId = try user.requireID()
        self.subjectId = try subject.requireID()
    }

//    static func create(for user: User, on subject: Subject, with conn: DatabaseConnectable) throws -> EventLoopFuture<SubjectTestSet> {
//
//        return conn.transaction(on: .psql) { (conn) in
//
//            return try Topic.query(on: conn)
//                .filter(\.subjectId == subject.requireID())
//                .join(\Topic.id, to: \Task.topicId)
//                .join(\Task.id, to: \MultipleChoiseTask.id)
//                .alsoDecode(MultipleChoiseTask.self).all()
//                .map({ (multipleChoises) in
//                    multipleChoises.map { task -> (Topic, SubjectTaskTestable) in
//                        (task.0, task.1)
//                    }
//                }).flatMap({ (tasks) -> EventLoopFuture<(SubjectTest, [(Topic, SubjectTaskTestable)])> in
//                    try SubjectTest(user: user, subject: subject)
//                        .create(on: conn)
//                        .and(result: tasks)
//                }).flatMap({ (info: SubjectTestCreateContent) in
//
//                    let set = try SubjectTestSet(test: info.test)
//
//                    return try info.tasks.map {
//                        try $0.task.assign(to: set, topic: $0.topic, on: conn)
//                    }.flatten(on: conn).transform(to: set)
//                })
//        }
//
//    }
}

extension SubjectTest {
    var tasks: Siblings<SubjectTest, Task, SubjectTestTaskExecution> {
        return siblings()
    }
}

extension SubjectTest: Migration {
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        return PostgreSQLDatabase.create(SubjectTest.self, on: conn) { builder in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.subjectId)
            builder.field(for: \.startTime)
            builder.field(for: \.endTime)
            builder.field(for: \.creatorId)

            builder.reference(from: \.creatorId, to: \User.id, onUpdate: .cascade, onDelete: .cascade)
            builder.reference(from: \.subjectId, to: \Subject.id, onUpdate: .cascade, onDelete: .restrict)
        }
    }

    static func revert(on connection: PostgreSQLConnection) -> Future<Void> {
        return PostgreSQLDatabase.delete(SubjectTest.self, on: connection)
    }
}
