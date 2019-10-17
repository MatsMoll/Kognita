//
//  PracticeSessionController.swift
//  App
//
//  Created by Mats Mollestad on 22/01/2019.
//

import Vapor
import FluentPostgreSQL
import KognitaCore
import KognitaViews

final class PracticeSessionController: RouteCollection, KognitaCRUDControllable {
    
    typealias Model = PracticeSession
    typealias ResponseContent = PracticeSession.Create.WebResponse
    
    static let shared = PracticeSessionController()

    func boot(router: Router) {
        router.post(
            "subjects", Subject.parameter, "practice-sessions/start",
            use: create)

        router.post(
            "practice-sessions", PracticeSession.parameter, "submit/multiple-choise",
            use: submitMultipleTaskAnswer)

        router.post(
            "practice-sessions", PracticeSession.parameter, "submit/input",
            use: submitInputTaskAnswer)

        router.post(
            "practice-sessions", PracticeSession.parameter, "submit/flash-card",
            use: submitFlashCardKnowledge)

        router.get(
            "practice-session/histogram",
            use: getAmountHistogram)

        router.post(
            "practice-session", PracticeSession.parameter,
            use: endSession)
    }
    
    
    func getAll(_ req: Request) throws -> EventLoopFuture<[PracticeSession.Create.WebResponse]> {
        throw Abort(.internalServerError)
    }
    
    func map(model: PracticeSession, on conn: DatabaseConnectable) throws -> EventLoopFuture<PracticeSession.Create.WebResponse> {
        
        return try model
            .getCurrentTaskIndex(conn)
            .map { index in
                return try .init(
                    redirectionUrl: model.pathFor(index: index)
                )
        }
    }
    
    func edit(_ req: Request) throws -> EventLoopFuture<PracticeSession.Create.Response> {
        throw Abort(.internalServerError)
    }
    
    func renderCurrentTask(on req: Request) throws -> Future<HTTPResponse> {

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
                        }
                }
        }
    }

    /// Submits an answer to a session
    ///
    /// - Parameter req: The http request
    /// - Returns: A response containing the result
    /// - Throws: if unautorized, database errors ext.
    func submitMultipleTaskAnswer(_ req: Request) throws -> Future<PracticeSessionResult<[MultipleChoiseTaskChoise.Result]>> {

        let user = try req.requireAuthenticated(User.self)

        return try req.content
            .decode(MultipleChoiseTask.Submit.self)
            .flatMap { submit in

                try req.parameters
                    .next(PracticeSession.self)
                    .flatMap { (session) in

                        try PracticeSession.Repository
                            .submitMultipleChoise(submit, in: session, by: user, on: req)
                }
        }
    }

    /// Submits an answer to a session
    ///
    /// - Parameter req: The http request
    /// - Returns: A response containing the result
    /// - Throws: if unautorized, database errors ext.
    func submitInputTaskAnswer(_ req: Request) throws -> Future<PracticeSessionResult<NumberInputTask.Submit.Response>> {

        let user = try req.requireAuthenticated(User.self)

        return try req.content
            .decode(NumberInputTask.Submit.Data.self)
            .flatMap { submit in

                try req.parameters
                    .next(PracticeSession.self)
                    .flatMap { session in

                        try PracticeSession.Repository
                            .submitInputTask(submit, in: session, by: user, on: req)
                }
        }
    }


    func submitFlashCardKnowledge(_ req: Request) throws -> Future<PracticeSessionResult<FlashCardTask.Submit>> {

        let user = try req.requireAuthenticated(User.self)

        return try req.content
            .decode(FlashCardTask.Submit.self)
            .flatMap { submit in

                try req.parameters
                    .next(PracticeSession.self)
                    .flatMap { session in

                        try PracticeSession.Repository
                            .submitFlashCard(submit, in: session, by: user, on: req)
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

    func endSession(_ req: Request) throws -> Future<PracticeSessionEndResponse> {

        let user = try req.requireAuthenticated(User.self)

        return try req.parameters
            .next(PracticeSession.self)
            .flatMap { session in
                try PracticeSession.Repository
                    .end(session, for: user, on: req)
                    .transform(to:
                        PracticeSessionEndResponse(sessionResultPath: "/practice-sessions/\(session.id ?? 0)/result")
                )
        }
    }
    
    func getAmountHistogram(_ req: Request) throws -> Future<[TaskResult.History]> {

        let user = try req.requireAuthenticated(User.self)

        return req.withPooledConnection(to: .psql) { conn in
            try TaskResultRepository
                .getAmountHistory(for: user, on: conn)
        }
    }
}


extension PSTaskResult: TaskResultable {}

struct PracticeSessionEndResponse: Content {
    let sessionResultPath: String
}

extension TaskType: RenderTaskPracticing {

    func render(in session: PracticeSession, index: Int, for user: User, on req: Request) throws -> EventLoopFuture<HTTPResponse> {

        return try renderableTask
            .render(in: session, index: index, for: user, on: req)
    }
    
    var renderableTask: RenderTaskPracticing {
        switch (multipleChoise, numberInputTask) {
        case (.some(let multiple),   _              ):  return multiple
        case (_,                    .some(let input)):  return input
        default:                                        return FlashCardTask(taskId: task.id)
        }
    }
}
