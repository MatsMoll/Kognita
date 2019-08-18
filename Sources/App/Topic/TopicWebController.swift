//
//  TopicWebController.swift
//  App
//
//  Created by Mats Mollestad on 08/10/2018.
//

import Vapor
import FluentSQL
import KognitaCore
import KognitaViews

final class TopicWebController: RouteCollection {

    let controller = TopicController.shared

    func boot(router: Router) throws {
        router.get("subjects", Subject.parameter, use: listAll)
        router.get("creator/subjects", Subject.parameter, "topics/create", use: createTopic)
        router.get("creator/subjects", Subject.parameter, "topics", Topic.parameter, "edit", use: editTopic)
        router.get("topics/", Topic.parameter, use: taskOverview)
    }

    func listAll(_ req: Request) throws -> EventLoopFuture<HTTPResponse> {

        let user = try req.requireAuthenticated(User.self)

        return try req.parameters
            .next(Subject.self)
            .flatMap { subject in

                try TopicRepository.shared
                    .getTopics(in: subject, conn: req)
                    .flatMap { topics in

                        req.withPooledConnection(to: .psql) { conn in

                            try TaskResultRepository.shared
                                .getUserLevel(for: user.requireID(), in: topics.map { try $0.requireID() }, on: conn)
                                .flatMap { levels in

                                    try TaskResultRepository.shared
                                        .getUserLevel(in: subject, userId: user.requireID(), on: conn)
                                        .map { subjectLevel in

                                            try req.renderer()
                                                .render(
                                                    SubjectDetailTemplate.self,
                                                    with: .init(
                                                        user: user,
                                                        subject: subject,
                                                        topics: topics,
                                                        levels: levels,
                                                        subjectLevel: subjectLevel
                                                    )
                                            )
                                    }
                            }
                        }
                }
        }
    }

    func createTopic(_ req: Request) throws -> Future<HTTPResponse> {

        let user = try req.requireAuthenticated(User.self)

        guard user.isCreator else {
            throw Abort(.forbidden)
        }

        return try req.parameters
            .next(Subject.self)
            .flatMap { subject in

                try TopicRepository.shared
                    .getTopics(in: subject, conn: req)
                    .map { topics in
                        
                        try req.renderer()
                            .render(
                                CreateTopicPage.self,
                                with: .init(
                                    user: user,
                                    subject: subject,
                                    topics: topics
                                )
                        )
                }
        }
    }

    func editTopic(_ req: Request) throws -> Future<HTTPResponse> {

        let user = try req.requireAuthenticated(User.self)

        guard user.isCreator else {
            throw Abort(.forbidden)
        }

        return try req.parameters
            .next(Subject.self)
            .flatMap { (subject) in

                try req.parameters
                    .next(Topic.self)
                    .flatMap { topic in

                        try TopicRepository.shared
                            .getTopics(in: subject, conn: req)
                            .map { topics in

                                try req.renderer()
                                    .render(
                                        CreateTopicPage.self,
                                        with: .init(
                                            user: user,
                                            subject: subject,
                                            topics: topics,
                                            topicInfo: topic
                                        )
                                )
                        }
                }
        }
    }


    func taskOverview(_ req: Request) throws -> Future<HTTPResponse> {

        let user = try req.requireAuthenticated(User.self)

        return try req.parameters
            .next(Topic.self)
            .flatMap { topic in

                SubjectRepository.shared
                    .getSubject(in: topic, on: req)
                    .flatMap { subject in

                        req.withPooledConnection(to: .psql) { conn in

                            try TaskResultRepository.shared
                                .getAllResults(for: user.requireID(), filter: \Topic.id == topic.requireID(), with: conn, maxRevisitDays: nil)
                                .flatMap { results in

                                    try Task.query(on: conn)
                                        .filter(\Task.topicId == topic.requireID())
                                        .filter(\Task.isOutdated == false)
                                        .all()
                                        .map { tasks in

                                            let resultOverview = tasks.map { task in
                                                TaskResultOverview(
                                                    result: results.first(where: { $0.taskID == task.id }),
                                                    task: task
                                                )
                                            }

                                            return try req.renderer()
                                                .render(
                                                    TaskOverviewListTemplate.self,
                                                    with: TaskOverviewListTemplate.Context.init(
                                                        user: user,
                                                        subject: subject,
                                                        topic: topic,
                                                        results: resultOverview
                                                    )
                                            )
                                    }
                            }
                        }
                }
        }
    }
}
