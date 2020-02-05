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

    func boot(router: Router) throws {

        let creatorSubjects = router.grouped("creator/subjects", Subject.parameter, "subtopics")

        creatorSubjects.get("create", use: create)
        creatorSubjects.get(Subtopic.parameter, "edit", use: edit)
    }


    func create(on req: Request) throws -> EventLoopFuture<HTTPResponse> {

        let user = try req.requireAuthenticated(User.self)

        return try req.parameters
            .model(Subject.self, on: req)
            .flatMap { subject in

                try User.DatabaseRepository
                    .isModerator(user: user, subjectID: subject.requireID(), on: req)
                    .flatMap {

                        try Topic.DatabaseRepository
                            .getTopics(in: subject, conn: req)
                            .map { topics in

                                try req.renderer().render(
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

    func edit(on req: Request) throws -> EventLoopFuture<HTTPResponse> {

       let user = try req.requireAuthenticated(User.self)

       return req.parameters
            .model(Subject.self, on: req)
           .flatMap { subject in

                try User.DatabaseRepository
                    .isModerator(user: user, subjectID: subject.requireID(), on: req)
                    .flatMap {

                        req.parameters
                            .model(Subtopic.self, on: req)
                            .flatMap { subtopic in

                                try Topic.DatabaseRepository
                                    .getTopics(in: subject, conn: req)
                                    .map { topics in

                                        try req.renderer().render(
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
