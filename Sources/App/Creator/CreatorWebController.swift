//
//  CreatorWebController.swift
//  App
//
//  Created by Mats Mollestad on 27/02/2019.
//

import Vapor
import Authentication
import KognitaCore
import KognitaViews

final class CreatorWebController: RouteCollection {

    func boot(router: Router) {
//        router.get("/creator/info", use: informationPage)
//        router.get("/creator/dashboard", use: dashboard)
        router.get("/creator/subjects", Subject.parameter, "overview", use: subjectOverview)
        router.get("/creator/overview/topics", Topic.parameter, use: topicOverview)
    }

    func informationPage(_ req: Request) throws -> HTTPResponse {
//        let user = try req.requireAuthenticated(User.self)
        throw Abort(.internalServerError)
//        return try req.renderer()
//            .render(CreatorInformationPage.self, with: .init(user: user))
    }

    func dashboard(_ req: Request) throws -> Future<HTTPResponse> {

        let user = try req.requireAuthenticated(User.self)

        guard user.isCreator else {
            throw Abort(.forbidden)
        }

        return req.databaseConnection(to: .psql)
            .flatMap { conn in

                try Topic.DatabaseRepository
                    .timelyTopics(on: conn)
                    .flatMap { topics in

                        try Task.Repository
                            .getTasks(where: \Task.creatorID == user.requireID(), maxAmount: 20, withSoftDeleted: true, conn: conn)
                            .map { tasks in

                                try req.renderer()
                                    .render(
                                        CreatorTemplates.Dashboard.self,
                                        with: .init(
                                            user: user,
                                            tasks: tasks,
                                            timelyTopics: topics
                                        )
                                )

                        }
                }
        }
    }

    func subjectOverview(_ req: Request) throws -> EventLoopFuture<HTTPResponse> {
        let user = try req.requireAuthenticated(User.self)

        guard user.isCreator else {
            throw Abort(.forbidden)
        }

        return try req.parameters
            .next(Subject.self)
            .flatMap { subject in

                try Task.Repository
                    .getTasks(in: subject.requireID(), maxAmount: nil, withSoftDeleted: true, conn: req)
                    .map { tasks in

                        try req.renderer()
                            .render(
                                Subject.Templates.ContentOverview.self,
                                with: .init(
                                    user: user,
                                    subject: subject,
                                    tasks: tasks
                                )
                        )
                }
        }
    }

    func topicOverview(_ req: Request) throws -> Future<HTTPResponse> {

        let user = try req.requireAuthenticated(User.self)

        guard user.isCreator else {
            throw Abort(.forbidden)
        }

        return try req.parameters
            .next(Topic.self)
            .flatMap { topic in

                Subject.DatabaseRepository
                    .getSubjectWith(id: topic.subjectId, on: req)
                    .flatMap { subject in

                        try Task.Repository
                            .getTasks(where: \Topic.id == topic.id, conn: req)
                            .map(to: HTTPResponse.self) { taskContent in

                                try req.renderer()
                                    .render(
                                        CreatorTemplates.TopicDetails.self,
                                        with: .init(
                                            user: user,
                                            subject: subject,
                                            topic: topic,
                                            tasks: taskContent
                                        )
                                )
                        }
                }
        }
    }
}

extension TaskContent: CreatorTaskContentable {
    public var deletedAt: Date? { return task.deletedAt }

    public var creatorName: String? { return creator?.username }

    public var subjectName: String { return subject.name }

    public var subjectID: Int { return subject.id ?? 0 }

    public var topicName: String { return topic.name }

    public var topicID: Int { return topic.id ?? 0 }

    public var taskID: Int { return task.id ?? 0 }

    public var question: String { return task.question }

    public var status: String { return "" }
}
