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
    }

    func createTopic(_ req: Request) throws -> EventLoopFuture<Response> {

        let user = try req.auth.require(User.self)

        return try req.controllers.subjectController.retrive(on: req)
            .flatMap { subject in

                req.repositories.userRepository
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

    func editTopic(_ req: Request) throws -> EventLoopFuture<Response> {

        let user = try req.auth.require(User.self)

        return try req.controllers.subjectController.retrive(on: req)
            .flatMap { subject in

                req.repositories.userRepository
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
