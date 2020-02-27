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

    func boot(router: Router) {
        let sessionInstance = router.grouped("practice-sessions/", TaskSession.PracticeParameter.parameter)

        router.get("practice-sessions/history",                     use: getSessions)

        sessionInstance.get("tasks", Int.parameter,                 use: renderCurrentTask)
        sessionInstance.get("tasks", Int.parameter, "solutions",    use: getSolutions)
        sessionInstance.get("result",                               use: getSessionResult)
        sessionInstance.post("end",                                 use: endSession)
    }

    func renderCurrentTask(on req: Request) throws -> EventLoopFuture<Response> {

        try PracticeSession.DefaultAPIController
            .getCurrentTask(on: req)
            .flatMap { currentTask in

                try currentTask.render(for: req)
                    .encode(for: req)
        }
        .catchFlatMap { error in
            switch error {
            case PracticeSession.DefaultAPIController.Errors
                .unableToFindTask(let session, let user):

                    return try PracticeSession.DatabaseRepository
                        .end(session, for: user, on: req)
                        .map { _ in
                            try req.redirect(to: "/practice-sessions/\(session.requireID())/result")
                    }
            default: throw error
            }
        }
    }


    /// Get the statistics of a session
    ///
    /// - Parameter req: The HTTP request
    /// - Returns: A rendered view
    /// - Throws: If unauth or any other error
    func getSessionResult(_ req: Request) throws -> EventLoopFuture<HTTPResponse> {

        let user = try req.requireAuthenticated(User.self)

        return try PracticeSession.DefaultAPIController
            .getSessionResult(req)
            .map { results in

                try req.renderer()
                    .render(
                        PracticeSession.Templates.Result.self,
                        with: .init(
                            user: user,
                            tasks: results,
                            progress: 0,
                            timeUsed: results.map { $0.result.timeUsed ?? 0 }.reduce(0, +)
                        )
                )
        }
    }

    /// Returns a session history
    func getSessions(_ req: Request) throws -> EventLoopFuture<HTTPResponse> {

        let user = try req.requireAuthenticated(User.self)

        return try PracticeSession.DatabaseRepository
            .getSessions(for: user, on: req)
            .flatMap { practiceSessions in

                try TestSession.DatabaseRepository
                    .getSessions(for: user, on: req)
                    .map { testSessions in

                        try req.renderer()
                            .render(
                                PracticeSession.Templates.History.self,
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

    func getSolutions(on req: Request) throws -> EventLoopFuture<HTTPResponse> {

        try PracticeSession.DefaultAPIController
            .get(solutions: req)
            .map { solutions in
                try req.renderer()
                    .render(
                        TaskSolution.Templates.List.self,
                        with: solutions
                )
        }
    }

    func endSession(on req: Request) throws -> EventLoopFuture<Response> {

        try PracticeSession.DefaultAPIController
            .end(session: req)
            .map { session in
                req.redirect(to: "/practice-sessions/\(session.id ?? 0)/result")
        }
    }
}


extension PSTaskResult: TaskResultable {
    public var topicId: Topic.ID { topic.id ?? 0 }
}

struct PracticeSessionEndResponse: Content {
    let sessionResultPath: String
}

extension TaskType: RenderTaskPracticing {

    func render(in session: PracticeSessionRepresentable, index: Int, for user: UserContent, on req: Request) throws -> EventLoopFuture<HTTPResponse> {

        return try renderableTask
            .render(in: session, index: index, for: user, on: req)
    }

    var renderableTask: RenderTaskPracticing {
        if let multiple = multipleChoise {
            return multiple
        } else {
            return FlashCardTask(taskId: task.id ?? 0)
        }
    }
}

extension PracticeSession.CurrentTask {
    func render(for req: Request) throws -> EventLoopFuture<HTTPResponse> {
        try task.render(
            in: session,
            index: index,
            for: user,
            on: req
        )
    }
}
