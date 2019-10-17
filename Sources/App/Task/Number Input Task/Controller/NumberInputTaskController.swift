//
//  NumberInputTaskController.swift
//  App
//
//  Created by Mats Mollestad on 23/03/2019.
//

import Vapor
import KognitaCore

final class NumberInputTaskController: KognitaCRUDControllable, RouteCollection {
    
    static let shared = NumberInputTaskController()

    typealias Model = NumberInputTask
    typealias Response = NumberInputTask.Data
    
    var parameter: PathComponentsRepresentable { return NumberInputTask.parameter }

    func boot(router: Router) {
        router.register(
            controller: self,
            at: "tasks/input")
        router.post(
            "tasks/input", NumberInputTask.parameter,
            use: submitAnswer)
    }
    
    func map(model: NumberInputTask, on conn: DatabaseConnectable) throws -> EventLoopFuture<NumberInputTask.Data> {
        return try NumberInputTask.Repository
            .get(task: model, conn: conn)
    }
    
    func mapCreate(response: NumberInputTask, on conn: DatabaseConnectable) throws -> EventLoopFuture<NumberInputTask.Data> {
        return try NumberInputTask.Repository
            .get(task: response, conn: conn)
    }

    func getAll(_ req: Request) throws -> EventLoopFuture<[NumberInputTask.Data]> {
        return NumberInputTask.Repository
            .all(on: req)
            .flatMap { tasks in

                return try tasks.map {
                    try NumberInputTask.Repository
                        .get(task: $0, conn: req)
                    }.flatten(on: req)
        }
    }

    func submitAnswer(_ req: Request) throws -> Future<PracticeSessionResult<NumberInputTask.Submit.Response>> {

        throw Abort(.internalServerError)
//        return try req.content.decode(NumberInputTaskSubmit.self).flatMap { submit in
//            try req.parameters.next(NumberInputTask.self).map { task in
//                task.evaluate(for: submit)
//            }
//        }
    }
}
