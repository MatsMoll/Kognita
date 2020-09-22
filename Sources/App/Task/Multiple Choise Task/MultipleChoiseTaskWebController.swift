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

                req.repositories.topicRepository
                    .topicsWithSubtopics(subjectID: subject.id)
                    .flatMap { topics in

                        req.repositories.userRepository
                            .isModerator(user: user, subjectID: subject.id)
                            .flatMapThrowing { isModerator in

                                try req.htmlkit
                                    .render(
                                        MultipleChoiceTask.Templates.Create.self,
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

    func editTask(_ req: Request) throws -> EventLoopFuture<Response> {

        let user = try req.auth.require(User.self)
        let taskID = try req.parameters.get(MultipleChoiceTask.self)

        return try req.repositories.multipleChoiceTaskRepository
            .modifyContent(forID: taskID)
            .flatMap { content in

                req.repositories.userRepository
                    .isModerator(user: user, taskID: taskID)
                    .flatMapThrowing { isModerator in

                        guard isModerator == true || content.task?.creatorID == user.id else {
                            throw Abort(.forbidden)
                        }
                        return try req.htmlkit
                            .render(
                                MultipleChoiceTask.Templates.Create.self,
                                with: .init(
                                    user: user,
                                    content: content,
                                    isModerator: isModerator,
                                    isTestable: false
                                )
                        )
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
