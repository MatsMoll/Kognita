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

    struct CreateTaskURLQuery: Content {
        let topicId: Int?
    }

    func boot(router: Router) throws {
        router.get(
            "creator/subjects", Subject.parameter, "task/flash-card/create",
            use: createTask)
        router.get(
            "creator/tasks/flash-card", FlashCardTask.parameter, "edit",
            use: editTask)

        router.get(
            "tasks/flash-card", FlashCardTask.parameter,
            use: getInstance)
    }

    func createTask(on req: Request) throws -> EventLoopFuture<HTTPResponse> {

        let user = try req.requireAuthenticated(User.self)

        let query = try req.query.decode(CreateTaskURLQuery.self)

        return try req.parameters
            .next(Subject.self)
            .flatMap { subject in

                try User.DatabaseRepository
                    .isModerator(user: user, subjectID: subject.requireID(), on: req)
                    .flatMap {

                        try Topic.DatabaseRepository
                            .getTopicResponses(in: subject, conn: req)
                            .map { topics in

                                try req.renderer().render(
                                    FlashCardTask.Templates.Create.self,
                                    with: .init(
                                        user: user,
                                        subject: subject,
                                        topics: topics,
                                        selectedTopicId: query.topicId
                                    )
                                )
                        }
                }
        }
    }

    func editTask(_ req: Request) throws -> EventLoopFuture<HTTPResponse> {

        let user = try req.requireAuthenticated(User.self)

        return try req.parameters
            .next(FlashCardTask.self)
            .flatMap { flashCard in

                FlashCardTask.DatabaseRepository
                    .content(for: flashCard, on: req)
                    .flatMap { content in

                        try Topic.DatabaseRepository
                            .getTopicResponses(in: content.subject, conn: req)
                            .map { topics in

                                try req.renderer()
                                    .render(
                                        FlashCardTask.Templates.Create.self,
                                        with: .init(
                                            user: user,
                                            subject: content.subject,
                                            topics: topics,
                                            content: content.task,
                                            selectedTopicId: content.topic.id
                                        )
                                )
                        }
                }
        }
    }


    func getInstance(_ req: Request) throws -> EventLoopFuture<HTTPResponse> {

        let user = try req.requireAuthenticated(User.self)

        return try req.parameters
            .next(FlashCardTask.self)
            .flatMap { flashCard in

                FlashCardTask.DatabaseRepository
                    .content(for: flashCard, on: req)
                    .map { preview in

                        try req.renderer().render(
                            FlashCardTask.Templates.Execute.self,
                            with: .init(
                                taskPreview: preview,
                                user: user.content(),
                                currentTaskIndex: nil,
                                numberOfTasks: 1
                            )
                        )
                }
        }
    }
}