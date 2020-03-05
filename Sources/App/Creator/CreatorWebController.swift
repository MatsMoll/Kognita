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

        router.get("/creator/subjects", Subject.parameter, "overview", use: subjectOverview)
        router.get("/creator/subjects", Subject.parameter, "search", use: search)
    }

    func subjectOverview(_ req: Request) throws -> EventLoopFuture<HTTPResponse> {
        let user = try req.requireAuthenticated(User.self)

        return req.parameters
            .model(Subject.self, on: req)
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

    func search(on req: Request) throws -> EventLoopFuture<HTTPResponse> {

        let user = try req.requireAuthenticated(User.self)

        let query = try req.query.decode(Task.Repository.CreatorOverviewQuery.self)

        return req.parameters
            .model(Subject.self, on: req)
            .flatMap { subject in

                try Task.Repository
                    .getTasks(in: subject.requireID(), query: query, withSoftDeleted: true, conn: req)
                    .map { tasks in

                        try req.renderer()
                            .render(Subject.Templates.TaskList.self, with: .init(
                                userID: user.requireID(),
                                tasks: tasks
                            )
                        )
                }
        }
    }
}
