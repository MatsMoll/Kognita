//
//  LectureNoteWebController.swift
//  App
//
//  Created by Mats Mollestad on 05/10/2020.
//

import Vapor
import KognitaModels

struct LectureNoteRecapSessionWebController: RouteCollection {

    func boot(routes: RoutesBuilder) throws {
        let recapInstance = routes.grouped("lecture-note-recap", LectureNote.RecapSession.parameter)
        recapInstance.get("tasks", Int.parameter, use: taskForIndex(on:))
        recapInstance.get("tasks", Int.parameter, "solutions", use: getSolutions)
        recapInstance.get("results", use: getSessionResult(_:))
    }

    func taskForIndex(on req: Request) throws -> EventLoopFuture<View> {

        return try req.controllers.lectureNoteRecapSessionController.taskForIndex(on: req)
            .flatMap { executeTask in

                LectureNote.RecapSession.Templates.ExecuteTask()
                    .render(
                        with: LectureNote.RecapSession.Templates.ExecuteTask.Context(executeTask: executeTask),
                        for: req
                    )
        }
    }

    func getSolutions(on req: Request) throws -> EventLoopFuture<Response> {

        let user = try req.auth.require(User.self)

        return try req.controllers.lectureNoteRecapSessionController
            .solutionForIndex(on: req)
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

    /// Get the statistics of a session
    ///
    /// - Parameter req: The HTTP request
    /// - Returns: A rendered view
    /// - Throws: If unauth or any other error
    func getSessionResult(_ req: Request) throws -> EventLoopFuture<Response> {

        let user = try req.auth.require(User.self)

        return try req.controllers.lectureNoteRecapSessionController
            .results(on: req)
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
}
