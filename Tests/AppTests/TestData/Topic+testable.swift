//
//  Topic+testable.swift
//  AppTests
//
//  Created by Mats Mollestad on 09/11/2018.
//

import Vapor
import FluentPostgreSQL
@testable import KognitaCore
@testable import App


extension Topic {
    static func create(name: String = "Topic", chapter: Int = 1, creator: User? = nil, subject: Subject? = nil, on conn: PostgreSQLConnection) throws -> Topic {

        let createSubject = try subject ?? Subject.create(creator: creator, on: conn)

        return try Topic.create(name: name, chapter: chapter, creatorId: createSubject.creatorId, subjectId: createSubject.requireID(), on: conn)
    }

    static func create(name: String = "Topic", chapter: Int = 1, creatorId: User.ID, subjectId: Subject.ID, on conn: PostgreSQLConnection) throws -> Topic {

        return try Topic(name: name, description: "", chapter: chapter, subjectId: subjectId, creatorId: creatorId)
            .save(on: conn)
            .wait()
    }
}
