//
//  FlashCardTask+testable.swift
//  KognitaCoreTests
//
//  Created by Eskild Brobak on 28/08/2019.
//

import Vapor
import FluentPostgreSQL
@testable import KognitaCore

extension FlashCardTask {
    
    static func create(creator:             User?       = nil,
                       subtopic:            Subtopic?      = nil,
                       task:                Task?       = nil,
                       on conn:             PostgreSQLConnection) throws -> FlashCardTask {
        
        let usedTask = try task ?? Task.create(creator: creator, subtopic: subtopic, on: conn)
        
        return try create(task: usedTask, on: conn)
    }
    
    static func create(task:                Task,
                       on conn:             PostgreSQLConnection) throws -> FlashCardTask {
        
        return try FlashCardTask(task: task)
            .create(on: conn)
            .wait()
    }
}
