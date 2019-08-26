//
//  SubtopicWebController.swift
//  App
//
//  Created by Mats Mollestad on 26/08/2019.
//

import Vapor
import KognitaCore
import KognitaViews

class SubtopicWebController : RouteCollection {

    func boot(router: Router) throws {
        router.get(
            "creator/subjects", Subject.parameter, "subtopics/create",
            use: create)
        router.get(
            "creator/subjects", Subject.parameter, "subtopics", Subtopic.parameter, "edit",
            use: edit)
        router.get("creator/subtopic-select-subject", use: selectSubject)
    }


    func create(on req: Request) throws -> Future<HTTPResponse> {

        let user = try req.requireAuthenticated(User.self)

        return try req.parameters
            .next(Subject.self)
            .flatMap { subject in

                try TopicRepository.shared
                    .getTopics(in: subject, conn: req)
                    .map { topics in

                        try req.renderer().render(
                            Subtopic.Create.Template.self,
                            with: .init(
                                user: user,
                                subject: subject,
                                topics: topics
                            )
                        )
                }
        }
    }

    func edit(on req: Request) throws -> Future<HTTPResponse> {

       let user = try req.requireAuthenticated(User.self)

       return try req.parameters
           .next(Subject.self)
           .flatMap { subject in

            try req.parameters
                .next(Subtopic.self)
                .flatMap { subtopic in

                    try TopicRepository.shared
                        .getTopics(in: subject, conn: req)
                        .map { topics in

                            try req.renderer().render(
                                Subtopic.Create.Template.self,
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

    func selectSubject(on req: Request) throws -> Future<HTTPResponse> {

        let user = try req.requireAuthenticated(User.self)

        guard user.isCreator else {
            throw Abort(.unauthorized)
        }

        return Subject.query(on: req)
            .all()
            .map { subjects in
                try req.renderer()
                    .render(
                        SelectSubjectTemplate.self,
                        with: .init(
                            user: user,
                            subjects: subjects,
                            redirectPathStart: "subjects/",
                            redirectPathEnd: "/subtopics/create"
                        )
                )
        }
    }
}
