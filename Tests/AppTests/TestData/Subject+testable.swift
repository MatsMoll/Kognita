//
//  Subject+testable.swift
//  AppTests
//
//  Created by Mats Mollestad on 09/11/2018.
//

import Vapor
import FluentPostgreSQL
@testable import KognitaCore
@testable import App


extension Subject {
    static func create(name: String = "Math", category: String = "Tech", colorClass: ColorClass = .primary, creator: User? = nil, on conn: PostgreSQLConnection) throws -> Subject {

        let createCreator = try creator ?? User.create(on: conn)
        return try Subject.create(name: name, category: category, colorClass: colorClass, creatorId: createCreator.requireID(), on: conn)
    }

    static func create(name: String = "Math", category: String = "Tech", colorClass: ColorClass = .primary, description: String = "Some description", creatorId: User.ID, on conn: PostgreSQLConnection) throws -> Subject {


        return try Subject(
            name: name,
            category: category,
            colorClass: colorClass,
            description: description,
            creatorId: creatorId
        )
            .save(on: conn)
            .wait()
    }
}
