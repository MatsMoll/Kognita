//
//  MultipleChoiseTaskWebController.swift
//  App
//
//  Created by Mats Mollestad on 12/01/2019.
//

import Vapor
import FluentPostgreSQL
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

    func boot(router: Router) {

        router.get(
            "creator/subjects", Subject.parameter, "task/multiple/create",
            use: createTask)
        router.get(
            "creator/tasks/multiple-choise", MultipleChoiseTask.parameter, "edit",
            use: editTask)
    }

    func createTask(_ req: Request) throws -> EventLoopFuture<HTTPResponse> {

        let user = try req.requireAuthenticated(User.self)

        let query = try req.query.decode(CreateTaskURLQuery.self)

        return req.parameters
            .model(Subject.self, on: req)
            .flatMap { subject in

                try Topic.DatabaseRepository
                    .getTopicResponses(in: subject, conn: req)
                    .flatMap { topics in

                        try User.DatabaseRepository.isModerator(user: user, subjectID: subject.requireID(), on: req)
                            .map { true }
                            .catchMap { _ in false }
                            .map { isModerator in

                                try req.renderer()
                                    .render(
                                        MultipleChoiseTask.Templates.Create.self,
                                        with: .init(
                                            user: user,
                                            content: .init(subject: subject, topics: topics),
                                            isModerator: isModerator,
                                            isTestable: query.isTestable ?? false
                                        )
                                )
                        }
                }
        }
    }

    func editTask(_ req: Request) throws -> EventLoopFuture<HTTPResponse> {

        let user = try req.requireAuthenticated(User.self)

        let query = try req.query.decode(EditTaskURLQuery.self)

        return req.parameters
            .model(MultipleChoiseTask.self, on: req)
            .flatMap { multiple in

                try MultipleChoiseTask.DatabaseRepository
                    .modifyContent(forID: multiple.requireID(), on: req)
                    .flatMap { content in

                        try User.DatabaseRepository.isModerator(user: user, taskID: multiple.requireID(), on: req)
                            .map { true }
                            .catchMap { _ in false }
                            .map { isModerator in

                                if isModerator || content.task?.creatorID == user.id {
                                    return try req.renderer()
                                        .render(
                                            MultipleChoiseTask.Templates.Create.self,
                                            with: .init(
                                                user: user,
                                                content: content,
                                                isModerator: isModerator,
                                                wasUpdated: query.wasUpdated ?? false
                                            )
                                    )
                                } else {
                                    throw Abort(.forbidden)
                                }
                        }
                }
        }
    }
}

final class MultipleChoiseTaskWebContent: Content {

    let topic: Topic
    let task: MultipleChoiseTask.Data
    let nextTaskID: MultipleChoiseTask.ID?

    init(taskContent: MultipleChoiseTask.Data, topic: Topic, nextTask: MultipleChoiseTask?) {
        self.task = taskContent
        self.topic = topic
        self.nextTaskID = nextTask?.id
    }
}
