//
//  CreatorWebController.swift
//  App
//
//  Created by Mats Mollestad on 27/02/2019.
//

import Vapor
import KognitaCore
import KognitaViews

final class CreatorWebController: RouteCollection {

    func boot(routes: RoutesBuilder) throws {
        routes.get("creator", "subjects", Subject.parameter, "overview", use: subjectOverview)
        routes.get("creator", "subjects", Subject.parameter, "search", use: search)
    }

    func subjectOverview(_ req: Request) throws -> EventLoopFuture<Response> {
        let user = try req.auth.require(User.self)

        return try req.controllers.subjectController
            .retrive(on: req)
            .flatMap { subject in

                req.repositories.subjectRepository
                    .tasksWith(subjectID: subject.id)
                    .failableFlatMap { tasks in

                        try req.repositories.taskSolutionRepository
                            .unverifiedSolutions(in: subject.id, for: user)
                            .flatMap { solutions in

                                req.repositories.userRepository
                                    .isModerator(user: user, subjectID: subject.id)
                                    .flatMapThrowing { isModerator in

                                        try req.htmlkit.render(
                                            Subject.Templates.ContentOverview.self,
                                            with: Subject.Templates.ContentOverview.Context(
                                                user: user,
                                                subject: subject,
                                                tasks: [],
                                                isModerator: isModerator,
                                                solutions: solutions
                                            )
                                        )
                                }
                        }
                }
        }
    }

    func search(on req: Request) throws -> EventLoopFuture<Response> {

        let user = try req.auth.require(User.self)

        throw Abort(.notImplemented)

//        let query = try req.query.decode(Task.Repository.CreatorOverviewQuery.self)
//
//        return req.parameters
//            .model(Subject.self, on: req)
//            .flatMap { subject in
//
//                try Task.Repository
//                    .getTasks(in: subject.requireID(), user: user, query: query, withSoftDeleted: true, conn: req)
//                    .flatMap { tasks in
//
//                        try User.DatabaseRepository
//                            .isModerator(user: user, subjectID: subject.requireID(), on: req)
//                            .map { true }
//                            .catchMap { _ in false }
//                            .map { isModerator in
//
//                                try req.renderer()
//                                    .render(Subject.Templates.TaskList.self, with: .init(
//                                        userID: user.requireID(),
//                                        isModerator: isModerator,
//                                        tasks: tasks
//                                    )
//                                )
//                        }
//                }
//        }
    }
}
