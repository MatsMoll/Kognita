//
//  MultipleChoiseTaskController.swift
//  AppTests
//
//  Created by Mats Mollestad on 11/11/2018.
//

import Vapor
import FluentPostgreSQL
import KognitaCore


final class MultipleChoiseTaskController: KognitaCRUDControllable, RouteCollection {
    
    typealias Model = MultipleChoiseTask
    typealias Response = MultipleChoiseTask.Data

    static let shared = MultipleChoiseTaskController()

    var parameter: PathComponentsRepresentable { return MultipleChoiseTask.parameter }

    func boot(router: Router) {
        router.register(controller: self, at: "tasks/multiple-choise")
        router.post(
            "tasks/multiple-choise", MultipleChoiseTask.parameter,
            use: submitAnswer)
    }
    
    func map(model: MultipleChoiseTask, on conn: DatabaseConnectable) throws -> EventLoopFuture<MultipleChoiseTask.Data> {
        
        return try MultipleChoiseTask.repository
            .get(task: model, conn: conn)
    }
    
    func mapCreate(response: MultipleChoiseTask, on conn: DatabaseConnectable) throws -> EventLoopFuture<MultipleChoiseTask.Data> {
        
        return try MultipleChoiseTask.repository
            .get(task: response, conn: conn)
    }
    
    func getAll(_ req: Request) throws -> EventLoopFuture<[MultipleChoiseTask.Data]> {
        return MultipleChoiseTask.repository
            .all(on: req)
            .flatMap { tasks in
                
                try tasks.map {
                    try MultipleChoiseTask.repository
                        .get(task: $0, conn: req)
                }.flatten(on: req)
        }
    }

    /// Submit an answer to a `MultipleChoiseTask`
    ///
    /// - Parameter req: The http request made
    /// - Returns: The result for each answer
    /// - Throws: On missing parameters, misformed content ext.
    func submitAnswer(on req: Request) throws -> Future<PracticeSessionResult<[MultipleChoiseTaskChoise.Result]>> {

        throw Abort(.internalServerError)

//        return try req.parameters.next(MultipleChoiseTask.self)
//            .flatMap { (task) in
//                try req.content.decode(MultipleChoiseTaskSubmit.self)
//                    .and(result: task)
//            }.flatMap { (submit, task) in
//                try task.evaluateAnswer(submit, on: req)
//            }
    }
}

