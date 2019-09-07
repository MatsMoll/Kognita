//
//  FlashCardTaskController.swift
//  App
//
//  Created by Mats Mollestad on 31/03/2019.
//

import Vapor
import KognitaCore

final class FlashCardTaskController: RouteCollection, KognitaCRUDControllable {
    
    typealias Model = FlashCardTask
    typealias ResponseContent = Task

    static var shared = FlashCardTaskController()
    
    var parameter: PathComponentsRepresentable { return FlashCardTask.parameter }

    func boot(router: Router) throws {
        router.register(controller: self, at: "tasks/flash-card")
    }
    
    func map(model: FlashCardTask, on conn: DatabaseConnectable) throws -> EventLoopFuture<Task> {
        return try FlashCardTask.repository
            .get(task: model, conn: conn)
    }
    
    func getAll(_ req: Request) throws -> EventLoopFuture<[Task]> {
        return FlashCardTask.query(on: req)
            .join(\FlashCardTask.id, to: \Task.id)
            .decode(Task.self)
            .all()
    }
}
