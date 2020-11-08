//
//  SubtopicWebController.swift
//  App
//
//  Created by Mats Mollestad on 26/08/2019.
//

import Vapor
import KognitaCore
import KognitaViews

class SubtopicWebController: RouteCollection {

    func boot(routes: RoutesBuilder) throws {

        let creatorSubjects = routes.grouped("creator", "subjects", Subject.parameter, "subtopics")

        creatorSubjects.get("create", use: create)
        creatorSubjects.get(Subtopic.parameter, "edit", use: edit)
    }

    func create(on req: Request) throws -> EventLoopFuture<Response> {

        let user = try req.auth.require(User.self)

        return try req.controllers.subjectController
            .retrive(on: req)
            .flatMap { subject in

                req.repositories { repositories in
                    repositories.userRepository
                        .isModerator(user: user, subjectID: subject.id)
                        .ifFalse(throw: Abort(.forbidden))
                        .failableFlatMap {

                            repositories.topicRepository
                                .getTopicsWith(subjectID: subject.id)
                                .flatMapThrowing { topics in

                                    try req.htmlkit.render(
                                        Subtopic.Templates.Create.self,
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

    func edit(on req: Request) throws -> EventLoopFuture<Response> {

        let user = try req.auth.require(User.self)

        return try req.controllers.subjectController.retrive(on: req)
            .flatMap { subject in

                req.repositories { repositories in
                    repositories.userRepository
                        .isModerator(user: user, subjectID: subject.id)
                        .ifFalse(throw: Abort(.forbidden))
                        .failableFlatMap {

                            try req.controllers.subtopicController.retrive(on: req)
                                .flatMap { subtopic in

                                    repositories.topicRepository
                                        .getTopicsWith(subjectID: subject.id)
                                        .flatMapThrowing { topics in

                                            try req.htmlkit.render(
                                                Subtopic.Templates.Create.self,
                                                with: .init(
                                                    user: user,
                                                    subject: subject,
                                                    topics: topics,
                                                    subtopicInfo: subtopic
                                                )
                                            )
                                    }
                            }
                    }
                }
        }
    }
}
