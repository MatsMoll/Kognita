//
//  MultipleChoiseTask+testable.swift
//  AppTests
//
//  Created by Mats Mollestad on 10/11/2018.
//

import Vapor
import FluentPostgreSQL
import XCTest
@testable import KognitaCore

extension MultipleChoiseTask {
    
    static func create(creator:             User?       = nil,
                       subtopic:               Subtopic?      = nil,
                       task:                Task?       = nil,
                       isMultipleSelect:    Bool        = true,
                       choises:             [MultipleChoiseTaskChoise.Data] = MultipleChoiseTaskChoise.Data.standard,
                       on conn:             PostgreSQLConnection) throws -> MultipleChoiseTask {
        
        let usedTask = try task ?? Task.create(creator: creator, subtopic: subtopic, on: conn)
        
        return try create(taskId: usedTask.requireID(),
                          isMultipleSelect: isMultipleSelect,
                          on: conn)
    }
    
    static func create(taskId:              Task.ID,
                       isMultipleSelect:    Bool        = true,
                       choises:             [MultipleChoiseTaskChoise.Data] = MultipleChoiseTaskChoise.Data.standard,
                       on conn:             PostgreSQLConnection) throws -> MultipleChoiseTask {
        
        return try MultipleChoiseTask(isMultipleSelect: isMultipleSelect, taskID: taskId)
            .create(on: conn)
            .flatMap { task in
                try choises.map {
                    try MultipleChoiseTaskChoise(content: $0, task: task)
                        .create(on: conn)
                }
                .flatten(on: conn)
                .transform(to: task)
        }
            .wait()
    }
}

extension MultipleChoiseTaskChoise.Data {
    static let standard: [MultipleChoiseTaskChoise.Data] = [
        .init(choise: "not", isCorrect: false),
        .init(choise: "yes", isCorrect: true),
        .init(choise: "not again", isCorrect: false)
    ]
}
