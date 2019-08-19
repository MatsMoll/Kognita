//
//  MultipleChoiseTask+testable.swift
//  AppTests
//
//  Created by Mats Mollestad on 10/11/2018.
//

import Vapor
import FluentPostgreSQL
@testable import KognitaCore
@testable import App
import XCTest

extension MultipleChoiseTask {
    
    static func create(creator:             User?       = nil,
                       topic:               Topic?      = nil,
                       task:                Task?       = nil,
                       isMultipleSelect:    Bool        = true,
                       on conn:             PostgreSQLConnection) throws -> MultipleChoiseTask {
        
        let usedTask = try task ?? Task.create(creator: creator, topic: topic, on: conn)
        
        return try create(creatorId: usedTask.creatorId,
                          taskId: usedTask.requireID(),
                          isMultipleSelect: isMultipleSelect,
                          on: conn)
    }
    
    static func create(creatorId:           User.ID,
                       taskId:              Task.ID,
                       isMultipleSelect:    Bool        = true,
                       on conn:             PostgreSQLConnection) throws -> MultipleChoiseTask {
        
        return try MultipleChoiseTask(isMultipleSelect: isMultipleSelect, taskID: taskId, creatorID: creatorId)
            .create(on: conn).flatMap { task in
                MultipleChoiseTaskChoise(choise: "Test", isCorrect: true, taskId: task.id!)
                    .create(on: conn)
                    .transform(to: task)
        }.wait()
    }
}
