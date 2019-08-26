//
//  Subtopic+testable.swift
//  KognitaCoreTests
//
//  Created by Mats Mollestad on 26/08/2019.
//

import Vapor
import FluentPostgreSQL
@testable import KognitaCore


extension Subtopic {
    static func create(name: String = "Topic", chapter: Int = 1, topic: Topic? = nil, on conn: PostgreSQLConnection) throws -> Subtopic {

        let usedTopic = try topic ?? Topic.create(on: conn)

        return try Subtopic.create(name: name, chapter: chapter, topicId: usedTopic.requireID(), on: conn)
    }

    static func create(name: String = "Topic", chapter: Int = 1, topicId: Topic.ID, on conn: PostgreSQLConnection) throws -> Subtopic {

        return try Subtopic(name: name, chapter: chapter, topicId: topicId)
            .save(on: conn)
            .wait()
    }
}

