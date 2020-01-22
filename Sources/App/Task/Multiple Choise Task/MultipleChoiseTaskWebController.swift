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

    struct CreateTaskURLQuery: Content {
        let topicId: Int?
    }

    static let shared = MultipleChoiseTaskWebController()

    func boot(router: Router) {

        router.get(
            "creator/subjects", Subject.parameter, "task/multiple/create",
            use: createTask)
        router.get(
            "creator/tasks/multiple-choise", MultipleChoiseTask.parameter, "edit",
            use: editTask)
//        router.get(
//            "topics", Topic.parameter, "tasks/multiple-choise",
//            use: getInstanceInTopic)
        router.get(
            "tasks/multiple-choise", MultipleChoiseTask.parameter,
            use: getInstance)
    }

    func getInstance(on req: Request) throws -> Future<HTTPResponse> {

        let user = try req.requireAuthenticated(User.self)

        return try req.parameters
            .next(MultipleChoiseTask.self)
            .flatMap { multiple in

                try MultipleChoiseTask.DatabaseRepository
                    .content(for: multiple, on: req)
                    .flatMap { preview, content in

                        return req.future().map {
                            try req.renderer().render(
                                MultipleChoiseTask.Templates.Execute.self,
                                with: .init(
                                    multiple: content,
                                    taskContent: preview,
                                    user: user.content(),
                                    currentTaskIndex: nil
                                )
                            )
                        }
                }
        }
    }

    func createTask(_ req: Request) throws -> Future<HTTPResponse> {

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

                                try req.renderer()
                                    .render(
                                        MultipleChoiseTask.Templates.Create.self,
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

    func editTask(_ req: Request) throws -> Future<HTTPResponse> {

        let user = try req.requireAuthenticated(User.self)

        return try req.parameters
            .next(MultipleChoiseTask.self)
            .flatMap { multiple in

                try User.DatabaseRepository.isModerator(user: user, taskID: multiple.requireID(), on: req)
                    .flatMap {

                        try MultipleChoiseTask.DatabaseRepository
                            .content(for: multiple, on: req)
                            .flatMap { preview, content in

                                try Topic.DatabaseRepository
                                    .getTopicResponses(in: preview.subject, conn: req)
                                    .map { topics in

                                        try req.renderer()
                                            .render(
                                                MultipleChoiseTask.Templates.Create.self,
                                                with: .init(
                                                    user: user,
                                                    subject: preview.subject,
                                                    topics: topics,
                                                    taskInfo: preview.task,
                                                    multipleTaskInfo: content
                                                )
                                        )
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