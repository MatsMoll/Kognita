////
////  UserTopicLevel.swift
////  App
////
////  Created by Mats Mollestad on 11/03/2019.
////
//
//import Vapor
//import FluentPostgreSQL
//import KognitaCore
//
//final class UserTopicLevel: PostgreSQLPivot {
//    typealias Left = User
//    typealias Right = Topic
//
//    static var leftIDKey: LeftIDKey = \.userID
//    static var rightIDKey: RightIDKey = \.topicID
//
//    static var createdAtKey: TimestampKey? = \.createdAt
//
//    var id: Int?
//
//    var createdAt: Date?
//
//    private(set) var userID: User.ID
//
//    private(set) var topicID: Topic.ID
//
//    private(set) var levelScore: Double
//
//    private(set) var numberOfCompletedTasks: Int
//
//    private(set) var totalScore: Double
//
//    init(userID: User.ID, topicID: Topic.ID) {
//        self.userID = userID
//        self.topicID = topicID
//        self.levelScore = 0
//        self.numberOfCompletedTasks = 0
//        self.totalScore = 0
//    }
//}
//
//extension UserTopicLevel {
//    var levelProsentage: Int {
//        return Int((levelScore * 100).rounded())
//    }
//}
//
//extension UserTopicLevel {
//    static func create(for user: User, with topic: Topic, on conn: DatabaseConnectable) throws -> Future<UserTopicLevel> {
//        return try UserTopicLevel(
//            userID:     user.requireID(),
//            topicID:    topic.requireID())
//            .save(on:   conn)
//    }
//
//    static func register<T>(_ result: PracticeSessionResult<T>, from task: Task, for userID: User.ID, on conn: DatabaseConnectable) -> Future<Double> {
//        return UserTopicLevel.query(on: conn)
//            .filter(\.userID == userID)
//            .filter(\.topicID == task.topicId)
//            .first().flatMap { level in
//                guard let level = level else {
//                    return UserTopicLevel(userID: userID, topicID: task.topicId)
//                        .save(on: conn).flatMap { _ in
//                            register(result, from: task, for: userID, on: conn)
//                    }
//                }
//                let difficulty = task.difficulty / (level.levelScore == 0 ? task.difficulty / 3 : level.levelScore)
//                let change = (difficulty * result.unforgivingScore / (20 * log(result.forgivingScore + 1.2))).clamped(to: -0.10...0.10)
//                let oldScore = level.levelScore
//                level.levelScore = (change + level.levelScore).clamped(to: 0...1)
//                level.totalScore += result.forgivingScore
//                level.numberOfCompletedTasks += 1
//                return level.save(on: conn)
//                    .transform(to: level.levelScore - oldScore)
//            }
//    }
//}
//
//extension UserTopicLevel: Migration {
//
//    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
//        return PostgreSQLDatabase.create(UserTopicLevel.self, on: conn) { builder in
//            try addProperties(to: builder)
//
//            builder.reference(from: \.userID, to: \User.id)
//            builder.reference(from: \.topicID, to: \Topic.id)
//
//            builder.unique(on: \.userID, \.topicID)
//        }
//    }
//
//    static func revert(on connection: PostgreSQLConnection) -> Future<Void> {
//        return PostgreSQLDatabase.delete(UserTopicLevel.self, on: connection)
//    }
//}
