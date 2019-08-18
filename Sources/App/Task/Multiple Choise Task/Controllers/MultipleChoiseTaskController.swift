//
//  MultipleChoiseTaskController.swift
//  AppTests
//
//  Created by Mats Mollestad on 11/11/2018.
//

import Vapor
import FluentPostgreSQL
import KognitaCore


class MultipleChoiseTaskController: CRUDControllable, RouteCollection {

    static let shared = MultipleChoiseTaskController()

    var parameter: PathComponentsRepresentable { return MultipleChoiseTask.parameter }

    func boot(router: Router) {
        router.register(controller: self, at: "tasks/multiple-choise")
        router.post(
            "tasks/multiple-choise", MultipleChoiseTask.parameter,
            use: submitAnswer)
    }

    func getInstanceCollection(_ req: Request) throws -> EventLoopFuture<[MultipleChoiseTaskContent]> {

        return MultipleChoiseTask
            .query(on: req)
            .all()
            .flatMap { (tasks) in

                try tasks.map {
                    try MultipleChoiseTaskRepository.shared
                        .get(task: $0, conn: req)
                    }.flatten(on: req)
        }
    }

    func getInstance(_ req: Request) throws -> EventLoopFuture<MultipleChoiseTaskContent> {

        return try req.parameters
            .next(MultipleChoiseTask.self)
            .flatMap { multipleChoise in

                try MultipleChoiseTaskRepository.shared
                    .get(task: multipleChoise, conn: req)
        }
    }

    func create(_ req: Request) throws -> EventLoopFuture<MultipleChoiseTaskContent> {

        let user = try req.requireAuthenticated(User.self)

        return try req.content
            .decode(MultipleChoiseTaskCreationContent.self)
            .flatMap { content in

                try MultipleChoiseTaskRepository.shared
                    .create(with: content, user: user, conn: req)
                    .flatMap { task in
                        try MultipleChoiseTaskRepository.shared
                            .get(task: task, conn: req)
                }
        }
    }

    func delete(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {

        let user = try req.requireAuthenticated(User.self)

        return try req.parameters
            .next(MultipleChoiseTask.self)
            .flatMap { multiple in

                try MultipleChoiseTaskRepository.shared
                    .delete(task: multiple, user: user, conn: req)
                    .transform(to: .ok)
            }
    }

    func edit(_ req: Request) throws -> EventLoopFuture<MultipleChoiseTaskContent> {

        let user = try req.requireAuthenticated(User.self)

        return try req.parameters
            .next(MultipleChoiseTask.self)
            .flatMap { multipleTask in

                try req.content
                    .decode(MultipleChoiseTaskCreationContent.self)
                    .flatMap { content in
                        
                        try MultipleChoiseTaskRepository.shared
                            .edit(task: multipleTask, with: content, user: user, conn: req)
                            .flatMap { task in
                                try MultipleChoiseTaskRepository.shared
                                    .get(task: task, conn: req)
                        }
            }
        }
    }

    /// Submit an answer to a `MultipleChoiseTask`
    ///
    /// - Parameter req: The http request made
    /// - Returns: The result for each answer
    /// - Throws: On missing parameters, misformed content ext.
    func submitAnswer(on req: Request) throws -> Future<PracticeSessionResult<[MultipleChoiseTaskChoiseResult]>> {

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

//final class MultipleChoiseTaskContent: Content {
//
//    let taskId: Int
//
//    let choises: [MultipleChoiseTaskChoise]
//
//    let isMultipleSelect: Bool
//
//    init(multipleTask: MultipleChoiseTask, choises: [MultipleChoiseTaskChoise]) throws {
//        self.taskId             = try multipleTask.requireID()
//        self.isMultipleSelect   = multipleTask.isMultipleSelect
//        self.choises            = choises
//    }
//}
