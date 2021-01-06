//
//  ExamSessionWebController.swift
//  KognitaCore
//
//  Created by Mats Mollestad on 07/11/2020.
//

import Vapor
import KognitaCore
import KognitaViews
import KognitaAPI

final class ExamSessionWebController: RouteCollection {

    func boot(routes: RoutesBuilder) throws {
        let sessionInstance = routes.grouped("exam-sessions", ExamSession.parameter)

        sessionInstance.get("tasks", Int.parameter, use: renderCurrentTask)
        sessionInstance.get("tasks", Int.parameter, "solutions", use: getSolutions)
        sessionInstance.get("result", use: getSessionResult)
        sessionInstance.post("end", use: endSession)
    }

    func renderCurrentTask(on req: Request) throws -> EventLoopFuture<Response> {

        try req.controllers.examSessionController
            .getCurrentTask(on: req)
            .flatMap { currentTask in

                currentTask.renderExamSession(on: req)
                    .encodeResponse(for: req)
        }
        .flatMapError { error in
            do {
                switch error {
                case ExamSessionAPIError.noTaskAtIndex(index: _, let sessionID):

                    return req.eventLoop.future()
                        .flatMapThrowing {
                            req.redirect(to: "/exam-sessions/\(sessionID)/result")
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
    func getSessionResult(_ req: Request) throws -> EventLoopFuture<View> {

        let user = try req.auth.require(User.self)

        return try req.controllers.examSessionController
            .getSessionResult(req)
            .flatMap { results in
                ExamSession.Templates.Result()
                    .render(
                        with: .init(
                            user: user,
                            result: results
                        ),
                        for: req
                    )
        }
    }

    func getSolutions(on req: Request) throws -> EventLoopFuture<Response> {

        let user = try req.auth.require(User.self)

        return try req.controllers.examSessionController
            .get(solutions: req)
            .flatMapThrowing { solutions in
                try req.htmlkit
                    .render(
                        TaskSolution.Templates.List.self,
                        with: .init(
                            user: user,
                            solutionResources: TaskSolution.Resources(solutions: solutions, resources: [])
                        )
                )
        }
    }

    func endSession(on req: Request) throws -> EventLoopFuture<Response> {

        try req.eventLoop.future(req.redirect(to: "/exam-sessions/\(req.parameters.get(ExamSession.self))/result"))
    }
}
