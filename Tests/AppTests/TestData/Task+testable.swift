//
//  Task+testable.swift
//  App
//
//  Created by Mats Mollestad on 09/11/2018.
//

import Vapor
import FluentPostgreSQL
@testable import KognitaCore

extension Task {
    
    static func create(creator:         User?           = nil,
                       subtopic:        Subtopic?       = nil,
                       estimateTime:    TimeInterval    = 60,
                       description:     String          = "Some description",
                       imageURL:        String?         = nil,
                       question:        String          = "Some question",
                       explenation:     String?         = nil,
                       on conn:         PostgreSQLConnection) throws -> Task {

        let usedCreator = try creator ?? User.create(on: conn)
        let usedSubtopic = try subtopic ?? Subtopic.create(on: conn)
        
        return try create(creatorId: usedCreator.requireID(),
                          subtopicId: usedSubtopic.requireID(),
                          estimateTime: estimateTime,
                          description: description,
                          imageURL: imageURL,
                          question: question,
                          explenation: explenation,
                          on: conn)
    }
    
    static func create(creatorId:       User.ID,
                       subtopicId:      Subtopic.ID,
                       estimateTime:    TimeInterval    = 60,
                       description:     String          = "Some description",
                       imageURL:        String?         = nil,
                       question:        String          = "Some question",
                       explenation:     String?         = nil,
                       on conn:         PostgreSQLConnection) throws -> Task {
        
        return try Task(subtopicId:     subtopicId,
                        estimatedTime:  estimateTime,
                        description:    description,
                        imageURL:       imageURL,
                        explenation:    explenation,
                        question:       question,
                        creatorId:      creatorId)
            .save(on: conn).wait()
    }
}
