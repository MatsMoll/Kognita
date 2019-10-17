//
//  NumberInputTaskWebController.swift
//  App
//
//  Created by Mats Mollestad on 23/03/2019.
//

import Vapor
import KognitaCore
import KognitaViews

class NumberInputTaskWebController: RouteCollection {

    struct CreateTaskURLQuery: Content {
        let topicId: Int?
    }

    func boot(router: Router) {
        router.get(
            "tasks/input", NumberInputTask.parameter,
            use: getInstance)
        router.get(
            "creator/subjects", Subject.parameter, "task/input/create",
            use: create)
        router.get(
            "creator/tasks/input", NumberInputTask.parameter, "edit",
            use: edit)
    }

    func getInstance(on req: Request) throws -> Future<HTTPResponse> {
        let user = try req.requireAuthenticated(User.self)

        return try req.parameters
            .next(NumberInputTask.self)
            .flatMap { task in

                try task.render(for: user, on: req)
        }
    }

    func create(on req: Request) throws -> Future<HTTPResponse> {

        let user = try req.requireAuthenticated(User.self)
        guard user.isCreator else {
            throw Abort(.forbidden)
        }

        let query = try req.query.decode(CreateTaskURLQuery.self)

        return try req.parameters
            .next(Subject.self).flatMap { subject in

                try Topic.Repository
                    .getTopicResponses(in: subject, conn: req)
                    .map { topics in

                        try req.renderer()
                            .render(
                                NumberInputTask.Templates.Create.self,
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

    func edit(_ req: Request) throws -> Future<HTTPResponse> {

        let user = try req.requireAuthenticated(User.self)
        guard user.isCreator else {
            throw Abort(.forbidden)
        }

        return try req.parameters
            .next(NumberInputTask.self)
            .flatMap { task in

                try NumberInputTask.Repository
                    .content(for: task, on: req)
                    .flatMap { preview, content in

                        try Topic.Repository
                            .getTopicResponses(in: preview.subject, conn: req)
                            .map { topics in

                                try req.renderer()
                                    .render(
                                        NumberInputTask.Templates.Create.self,
                                        with: .init(
                                            user: user,
                                            topics: topics,
                                            preview: preview,
                                            content: content
                                        )
                                )
                        }
                }
        }
    }
}
