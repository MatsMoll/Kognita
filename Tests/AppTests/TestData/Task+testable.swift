//
//  Task+testable.swift
//  App
//
//  Created by Mats Mollestad on 09/11/2018.
//

import Vapor
import FluentPostgreSQL
@testable import KognitaCore
@testable import App

extension Task {
    
    static func create(creator:         User?           = nil,
                       topic:           Topic?          = nil,
                       estimateTime:    TimeInterval    = 60,
                       description:     String          = "Some description",
                       imageURL:        String?         = nil,
                       question:        String          = "Some question",
                       explenation:     String?         = nil,
                       on conn:         PostgreSQLConnection) throws -> Task {
        
        let usedTopic = try topic ?? Topic.create(creator: creator, on: conn)
        
        return try create(creatorId: usedTopic.creatorId,
                          topicId: usedTopic.requireID(),
                          estimateTime: estimateTime,
                          description: description,
                          imageURL: imageURL,
                          question: question,
                          explenation: explenation,
                          on: conn)
    }
    
    static func create(creatorId:       User.ID,
                       topicId:         Topic.ID,
                       estimateTime:    TimeInterval    = 60,
                       description:     String          = "Some description",
                       imageURL:        String?         = nil,
                       question:        String          = "Some question",
                       explenation:     String?         = nil,
                       on conn:         PostgreSQLConnection) throws -> Task {
        
        return try Task(topicId:        topicId,
                        estimatedTime:  estimateTime,
                        description:    description,
                        imageURL:       imageURL,
                        explenation:    explenation,
                        question:       question,
                        creatorId:      creatorId)
            .save(on: conn).wait()
    }
}
