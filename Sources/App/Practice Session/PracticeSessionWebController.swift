//
//  PracticeSessionWebController.swift
//  App
//
//  Created by Mats Mollestad on 21/10/2019.
//

import Vapor
import KognitaCore
import KognitaViews

final class PracticeSessionWebController: RouteCollection {

    private let controller = PracticeSessionController.shared

    func boot(router: Router) {
        router.get("practice-sessions/", PracticeSession.parameter, "tasks", Int.parameter, use: renderCurrentTask)
        router.get("practice-sessions/", PracticeSession.parameter, "tasks", Int.parameter, "solutions", use: getSolutions)
        router.get("practice-sessions/", PracticeSession.parameter, "result", use: getSessionResult)
        router.get("practice-sessions/history", use: getSessions)
    }

    func renderCurrentTask(on req: Request) throws -> Future<Response> {

        let user = try req.requireAuthenticated(User.self)

        return try req.parameters
            .next(PracticeSession.self)
            .flatMap { (session) in

                guard session.userID == user.id else {
                    throw Abort(.forbidden)
                }

                let index = try req.parameters.next(Int.self)
                return req.databaseConnection(to: .psql)
                    .flatMap { conn in

                        try session
                            .taskAt(index: index, on: conn)
                            .flatMap { task in
                                try task.render(in: session, index: index, for: user, on: req)
                                    .encode(for: req)
                        }
                        .catchFlatMap { _ in
                            try PracticeSession.Repository
                                .end(session, for: user, on: conn)
                                .map { _ in
                                    try req.redirect(to: "/practice-sessions/\(session.requireID())/result")
                            }
                        }
                }
        }
    }


    /// Get the statistics of a session
    ///
    /// - Parameter req: The HTTP request
    /// - Returns: A rendered view
    /// - Throws: If unauth or any other error
    func getSessionResult(_ req: Request) throws -> Future<HTTPResponse> {

        let user = try req.requireAuthenticated(User.self)


        return try req.parameters
            .next(PracticeSession.self)
            .flatMap { session in
                guard user.id == session.userID else {
                    throw Abort(.forbidden)
                }

                return try PracticeSession.Repository
                    .goalProgress(in: session, on: req)
                    .flatMap { progress in

                        try PracticeSession.Repository
                            .getResult(for: session, on: req)
                            .map { results in

                                try req.renderer()
                                    .render(
                                        PracticeSession.Templates.Result.self,
                                        with: .init(
                                            user: user,
                                            tasks: results,
                                            progress: progress,
                                            timeUsed: results.map { $0.result.timeUsed }.reduce(0, +)
                                        )
                                )
                        }
                }
        }
    }

    /// Returns a session history
    func getSessions(_ req: Request) throws -> Future<HTTPResponse> {

        let user = try req.requireAuthenticated(User.self)

        return try PracticeSession.Repository
            .getAllSessions(by: user, on: req)
            .map { sessions in

                try req.renderer()
                    .render(
                        PracticeSession.Templates.History.self,
                        with: .init(
                            user: user,
                            sessions: sessions
                        )
                )
        }
    }

    func getSolutions(on req: Request) throws -> EventLoopFuture<HTTPResponse> {

        let user = try req.requireAuthenticated(User.self)

        return try req.parameters
            .next(PracticeSession.self)
            .flatMap { (session) in

                guard session.userID == user.id else {
                    throw Abort(.forbidden)
                }

                let index = try req.parameters.next(Int.self)
                return try PracticeSession.Repository.taskID(index: index, in: session, on: req)
                    .flatMap { taskID in
                        TaskSolution.Repository.solutions(for: taskID, on: req)
                            .map { solutions in
                                try req.renderer().render(TaskSolutionsTemplate.self, with: solutions)
                        }
                }
        }
    }
}
