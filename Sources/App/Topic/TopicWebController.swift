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
import HTMLKit

final class TopicWebController: RouteCollection {

    func boot(routes: RoutesBuilder) throws {
        routes.get("creator", "subjects", Subject.parameter, "topics", "create", use: createTopic)
        routes.get("creator", "subjects", Subject.parameter, "topics", Topic.parameter, "edit", use: editTopic)
        routes.get("subjects", Subject.parameter, "topics", use: modifyTopics)
        routes.get("subjects", Subject.parameter, "topics", "row", use: topicRow)
    }

    func createTopic(_ req: Request) throws -> EventLoopFuture<Response> {

        let user = try req.auth.require(User.self)

        return try req.controllers.subjectController.retrive(on: req)
            .flatMap { subject in

                req.repositories { repositories in
                    repositories.userRepository
                        .isModerator(user: user, subjectID: subject.id)
                        .ifFalse(throw: Abort(.forbidden))
                        .flatMapThrowing {

                            try req.htmlkit
                                .render(
                                    Topic.Templates.Create.self,
                                    with: .init(
                                        user: user,
                                        subject: subject
                                    )
                            )
                    }
                }
        }
    }

    func editTopic(_ req: Request) throws -> EventLoopFuture<Response> {

        let user = try req.auth.require(User.self)

        return try req.controllers.subjectController.retrive(on: req)
            .flatMap { subject in

                req.repositories { repositories in
                    repositories.userRepository
                        .isModerator(user: user, subjectID: subject.id)
                        .ifFalse(throw: Abort(.forbidden))
                        .failableFlatMap {

                            try req.controllers.topicController
                                .retrive(req)
                                .flatMapThrowing { topic in

                                    try req.htmlkit
                                        .render(
                                            Topic.Templates.Create.self,
                                            with: .init(
                                                user: user,
                                                subject: subject,
                                                topicInfo: topic
                                            )
                                    )
                            }
                    }
                }
        }
    }

    func modifyTopics(on req: Request) throws -> EventLoopFuture<Response> {

        let user = try req.auth.require(User.self)

        return try req.controllers.subjectController.retrive(on: req)
            .flatMap { subject in

                req.repositories { repositories in
                    repositories.userRepository
                        .isModerator(user: user, subjectID: subject.id)
                        .ifFalse(throw: Abort(.forbidden))
                        .failableFlatMap {

                            try req.controllers.topicController
                                .getAllIn(subject: req)
                                .flatMapThrowing { topics in

                                    try req.htmlkit
                                        .render(
                                            Topic.Templates.Modify.self,
                                            with: .init(
                                                user: user,
                                                subject: subject,
                                                topics: topics
                                            )
                                    )
                            }
                    }
                }
        }
    }

    func topicRow(req: Request) throws -> EventLoopFuture<View> {
        try Topic.Templates.Modify.TopicRow().render(with: req.query.decode(Topic.self), for: req)
    }
}

struct SubjectSelectTaskPath: Decodable {
    let taskType: String?

    var endPath: String {
        if let taskType = taskType {
            return "/task/\(taskType)/create"
        } else {
            return "/topics/create"
        }
    }
}
