//
//  MultipleChoiseTaskWebController.swift
//  App
//
//  Created by Mats Mollestad on 12/01/2019.
//

import Vapor
import KognitaCore
import KognitaViews

final class MultipleChoiseTaskWebController: RouteCollection {

    struct EditTaskURLQuery: Content {
        let wasUpdated: Bool?
    }

    struct CreateTaskURLQuery: Content {
        let isTestable: Bool?
    }

    static let shared = MultipleChoiseTaskWebController()

    func boot(routes: RoutesBuilder) throws {

        routes.get(
            "creator", "subjects", Subject.parameter, "task", "multiple", "create",
            use: createTask)
        routes.get(
            "creator", "tasks", "multiple-choise", MultipleChoiceTask.parameter, "edit",
            use: editTask)
    }

    func createTask(_ req: Request) throws -> EventLoopFuture<Response> {

        let user = try req.auth.require(User.self)

        let query = try req.query.decode(CreateTaskURLQuery.self)

        return try req.controllers.subjectController
            .retrive(on: req)
            .flatMap { subject in

                req.repositories.userRepository
                    .isModerator(user: user, subjectID: subject.id)
                    .flatMapThrowing { isModerator in

                        try req.htmlkit
                            .render(
                                MultipleChoiceTask.Templates.Create.self,
                                with: .init(
                                    user: user,
                                    content: .init(subject: subject, topics: []),
                                    isModerator: isModerator,
                                    isTestable: query.isTestable ?? false
                                )
                        )
                }
        }
    }

    func editTask(_ req: Request) throws -> EventLoopFuture<Response> {

        let user = try req.auth.require(User.self)

        let query = try req.query.decode(EditTaskURLQuery.self)

        return try req.repositories.multipleChoiceTaskRepository
            .modifyContent(forID: req.parameters.get(MultipleChoiceTask.self))
            .flatMap { content in

                req.repositories.userRepository
                    .isModerator(user: user, taskID: content.id)
                    .flatMapThrowing { _ in

                        throw Abort(.notImplemented)
//                        if isModerator || content.task?.creatorID == user.id {
//                            try req.htmlkit
//                                .render(
//                                    MultipleChoiceTask.Templates.Create.self,
//                                    with: .init(
//                                        user: user,
//                                        content: content,
//                                        isModerator: isModerator,
//                                        isTestable: query.isTestable ?? false
//                                    )
//                            )
//                        } else {
//                            throw Abort(.forbidden)
//                        }
                }
        }
    }
}

final class MultipleChoiseTaskWebContent: Content {

    let topic: Topic
    let task: MultipleChoiceTask
    let nextTaskID: MultipleChoiceTask.ID?

    init(taskContent: MultipleChoiceTask, topic: Topic, nextTask: MultipleChoiceTask?) {
        self.task = taskContent
        self.topic = topic
        self.nextTaskID = nextTask?.id
    }
}
