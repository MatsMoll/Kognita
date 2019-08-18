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
    static func create(name: String = "Math", code: String? = nil, creator: User? = nil, on conn: PostgreSQLConnection) throws -> Subject {
        
        let createCreator = try creator ?? User.create(on: conn)
        return try Subject.create(name: name, code: code, creatorId: createCreator.requireID(), on: conn)
    }
    
    static func create(name: String = "Math", code: String? = nil, imageURL: String = "https://www.hey.no/image.png", description: String = "Some description", creatorId: User.ID, on conn: PostgreSQLConnection) throws -> Subject {
        
        let createCode = code ?? "REA\(Int.random(in: 1000...999999))"
        
        return try Subject(code: createCode,
                           name: name,
                           imageURL: imageURL,
                           description: description,
                           creatorId: creatorId)
            .save(on: conn).wait()
    }
}
