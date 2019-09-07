//
//  NumberInputTask+testable.swift
//  KognitaCoreTests
//
//  Created by Eskild Brobak on 01/09/2019.
//

import Vapor
import FluentPostgreSQL
@testable import KognitaCore

extension NumberInputTask {
    
    static func create(creator:             User?       = nil,
                       subtopic:            Subtopic?   = nil,
                       task:                Task?       = nil,
                       correctAnswer:       Double      = 0,
                       unit:                String?     = nil,
                       on conn:             PostgreSQLConnection) throws -> NumberInputTask {
        
        let usedTask = try task ?? Task.create(creator: creator, subtopic: subtopic, on: conn)
        
        return try create(correctAnswer: correctAnswer, unit: unit, taskId: usedTask.requireID(), on: conn)
    }
    
    static func create(correctAnswer:   Double,
                       unit:            String?,
                       taskId:          Task.ID,
                       on conn:         PostgreSQLConnection) throws -> NumberInputTask {
        
        return try NumberInputTask(correctAnswer: correctAnswer, unit: unit, taskId: taskId)
            .create(on: conn)
            .wait()
    }
}

