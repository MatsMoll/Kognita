//
//  PracticeSessionWebController.swift
//  App
//
//  Created by Mats Mollestad on 21/10/2019.
//

import Vapor
import KognitaCore
import KognitaViews
import KognitaAPI

final class PracticeSessionWebController: RouteCollection {

    func boot(routes: RoutesBuilder) throws {
        let sessionInstance = routes.grouped("practice-sessions", PracticeSession.parameter)

        routes.get("practice-sessions", "history", use: getSessions)

        sessionInstance.get("tasks", Int.parameter, use: renderCurrentTask)
        sessionInstance.get("tasks", Int.parameter, "solutions", use: getSolutions)
        sessionInstance.get("result", use: getSessionResult)
        sessionInstance.post("end", use: endSession)
    }

    func renderCurrentTask(on req: Request) throws -> EventLoopFuture<Response> {

        try req.controllers.practiceSessionController
            .getCurrentTask(on: req)
            .flatMap { currentTask in

                currentTask.render(on: req)
        }
        .flatMapError { error in
            do {
                switch error {
                case PracticeSession.DefaultAPIController.Errors
                    .unableToFindTask(let session, let user):

                    return try req.repositories.practiceSessionRepository
                        .end(sessionID: session.requireID(), for: user)
                        .flatMapThrowing {
                            try req.redirect(to: "/practice-sessions/\(session.requireID())/result")
                        }
                default: throw error
                }
            } catch {
                return req.eventLoop.future(error: error)
            }
        }
    }

    /// Get the statistics of a session
    ///
    /// - Parameter req: The HTTP request
    /// - Returns: A rendered view
    /// - Throws: If unauth or any other error
    func getSessionResult(_ req: Request) throws -> EventLoopFuture<Response> {

        let user = try req.auth.require(User.self)

        return try req.controllers.practiceSessionController
            .getSessionResult(req)
            .flatMapThrowing { results in

                try req.htmlkit
                    .render(
                        PracticeSession.Templates.Result.self,
                        with: .init(
                            user: user,
                            result: results
                        )
                )
        }
    }

    /// Returns a session history
    func getSessions(_ req: Request) throws -> EventLoopFuture<Response> {

        let user = try req.auth.require(User.self)

        return try req.repositories.practiceSessionRepository
            .getSessions(for: user)
            .flatMap { practiceSessions in

                req.repositories.testSessionRepository
                    .getSessions(for: user)
                    .flatMapThrowing { testSessions in

                        try req.htmlkit
                            .render(
                                Sessions.Templates.History.self,
                                with: .init(
                                    user: user,
                                    sessions: .init(
                                        testSessions: testSessions,
                                        practiceSessions: practiceSessions
                                    )
                                )
                        )
                }
        }
    }

    func getSolutions(on req: Request) throws -> EventLoopFuture<Response> {

        let user = try req.auth.require(User.self)

        return try req.controllers.practiceSessionController
            .get(solutions: req)
            .flatMapThrowing { solutions in
                try req.htmlkit
                    .render(
                        TaskSolution.Templates.List.self,
                        with: .init(
                            user: user,
                            solutions: solutions
                        )
                )
        }
    }

    func endSession(on req: Request) throws -> EventLoopFuture<Response> {

        try req.controllers.practiceSessionController
            .end(session: req)
            .map { session in
                req.redirect(to: "/practice-sessions/\(session.id)/result")
        }
    }
}

struct PracticeSessionEndResponse: Content {
    let sessionResultPath: String
}
