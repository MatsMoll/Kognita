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
        router.get("/creator/info", use: informationPage)
        router.get("/creator/dashboard", use: dashboard)
        router.get("/creator/overview/topics", Topic.parameter, use: topicOverview)
    }

    func informationPage(_ req: Request) throws -> HTTPResponse {
        let user = try req.requireAuthenticated(User.self)
        return try req.renderer()
            .render(CreatorInformationPage.self, with: .init(user: user))
    }

    func dashboard(_ req: Request) throws -> Future<HTTPResponse> {

        let user = try req.requireAuthenticated(User.self)

        guard user.isCreator else {
            throw Abort(.forbidden)
        }

        return req.withPooledConnection(to: .psql) { conn in

            try TopicRepository.shared
                .timelyTopics(on: conn)
                .flatMap { topics in

                    try TaskRepository.shared
                        .getTasks(where: \Task.creatorId == user.requireID(), maxAmount: 20, withSoftDeleted: true, conn: conn)
                        .map { tasks in

                            try req.renderer()
                                .render(
                                    CreatorDashboard.self,
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

    func topicOverview(_ req: Request) throws -> Future<HTTPResponse> {

        let user = try req.requireAuthenticated(User.self)

        guard user.isCreator else {
            throw Abort(.forbidden)
        }

        return try req.parameters
            .next(Topic.self)
            .flatMap { topic in

                SubjectRepository.shared
                    .getSubjectWith(id: topic.subjectId, on: req)
                    .flatMap { subject in

                        try TaskRepository.shared
                            .getTasks(where: \Topic.id == topic.id, conn: req)
                            .map(to: HTTPResponse.self) { taskContent in

                                try req.renderer()
                                    .render(
                                        CreatorTopicPage.self,
                                        with: CreatorTopicPage.Context(
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

extension TaskContent: CreatorTaskContent {
    public var deletedAt: Date? { return task.deletedAt }

    public var creatorName: String? { return creator?.name }

    public var subjectName: String { return subject.name }

    public var subjectID: Int { return subject.id ?? 0 }

    public var topicName: String { return topic.name }

    public var topicID: Int { return topic.id ?? 0 }

    public var taskID: Int { return task.id ?? 0 }

    public var question: String { return task.question }

    public var status: String { return "" }
}
