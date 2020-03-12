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
                    .getTasks(in: subject.requireID(), user: user, maxAmount: nil, withSoftDeleted: true, conn: req)
                    .flatMap { tasks in

                        try Subject.DatabaseRepository
                            .unverifiedSolutions(in: subject.requireID(), for: user, on: req)
                            .flatMap { solutions in

                                try User.DatabaseRepository
                                    .isModerator(user: user, subjectID: subject.requireID(), on: req)
                                    .map { true }
                                    .catchMap { _ in false }
                                    .map { isModerator in

                                        try req.renderer()
                                            .render(
                                                Subject.Templates.ContentOverview.self,
                                                with: .init(
                                                    user: user,
                                                    subject: subject,
                                                    tasks: tasks,
                                                    isModerator: isModerator,
                                                    solutions: solutions
                                                )
                                        )
                                }
                        }
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
                    .getTasks(in: subject.requireID(), user: user, query: query, withSoftDeleted: true, conn: req)
                    .flatMap { tasks in

                        try User.DatabaseRepository
                            .isModerator(user: user, subjectID: subject.requireID(), on: req)
                            .map { true }
                            .catchMap { _ in false }
                            .map { isModerator in

                                try req.renderer()
                                    .render(Subject.Templates.TaskList.self, with: .init(
                                        userID: user.requireID(),
                                        isModerator: isModerator,
                                        tasks: tasks
                                    )
                                )
                        }
                }
        }
    }
}
