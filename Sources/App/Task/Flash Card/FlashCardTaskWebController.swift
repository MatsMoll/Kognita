//
//  FlashCardTaskWebController.swift
//  App
//
//  Created by Mats Mollestad on 31/03/2019.
//

import Vapor
import KognitaCore
import KognitaViews

class FlashCardTaskWebController: RouteCollection {

    struct EditTaskURLQuery: Content {
        let wasUpdated: Bool?
    }

    func boot(routes: RoutesBuilder) throws {

        routes.get(
            "creator", "subjects", Subject.parameter, "task", "flash-card", "create",
            use: createTask)
        routes.get(
            "creator", "tasks", "flash-card", TypingTask.parameter, "edit",
            use: editTask)
    }

    func createTask(on req: Request) throws -> EventLoopFuture<Response> {

        let user = try req.auth.require(User.self)

        return try req.controllers.subjectController
            .overview(on: req)
            .flatMapThrowing { subject in

                try req.htmlkit.render(
                    TypingTask.Templates.Create.self,
                    with: .init(
                        user: user,
                        content: .init(subject: subject),
                        canEdit: true
                    )
                )
        }
    }

    func editTask(_ req: Request) throws -> EventLoopFuture<Response> {

        let user = try req.auth.require(User.self)

        let query = try req.query.decode(EditTaskURLQuery.self)

        return try req.repositories.typingTaskRepository
            .modifyContent(forID: req.parameters.get(TypingTask.self))
            .flatMap { content in

                    return req.repositories.userRepository
                        .isModerator(user: user, taskID: content.task!.id)
                        .flatMapThrowing { isModerator in

                            try req.htmlkit
                                .render(
                                    TypingTask.Templates.Create.self,
                                    with: .init(
                                        user: user,
                                        content: content,
                                        canEdit: isModerator || content.task?.creatorID == user.id,
                                        wasUpdated: query.wasUpdated ?? false
                                    )
                            )
                }
        }
    }
}
