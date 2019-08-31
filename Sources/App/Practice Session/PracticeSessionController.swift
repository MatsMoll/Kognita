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
    typealias ResponseContent = PracticeSession.Create.Response
    
    static let shared = PracticeSessionController()

    func boot(router: Router) {
        router.post(
            "subjects", Subject.parameter, "practice-sessions/start",
            use: create)

        router.post(
            "practice-sessions", PracticeSession.parameter, "tasks/multiple-choise/current",
            use: submitMultipleTaskAnswer)

        router.post(
            "practice-sessions", PracticeSession.parameter, "tasks/input/current",
            use: submitInputTaskAnswer)

        router.post(
            "practice-sessions", PracticeSession.parameter, "tasks/flash-card/current",
            use: submitFlashCardKnowledge)

        router.get(
            "practice-session/histogram",
            use: getAmountHistogram)

        router.post(
            "practice-session", PracticeSession.parameter,
            use: endSession)
    }
    
    func getAll(_ req: Request) throws -> EventLoopFuture<[PracticeSession.Create.Response]> {
        throw Abort(.internalServerError)
    }
    
    func map(model: PracticeSession, on conn: DatabaseConnectable) throws -> EventLoopFuture<PracticeSession.Create.Response> {
        throw Abort(.internalServerError)
    }
    
    func edit(_ req: Request) throws -> EventLoopFuture<PracticeSession.Create.Response> {
        throw Abort(.internalServerError)
    }
    
    func renderCurrentTask<T>(_ taskType: T.Type, on req: Request) throws -> Future<Response> where T: PostgreSQLModel, T: RenderTaskPracticing {

        let user = try req.requireAuthenticated(User.self)

        return try req.parameters
            .next(PracticeSession.self)
            .flatMap { (session) in

                guard session.userID == user.id else {
                    throw Abort(.forbidden)
                }
                if session.hasAssignedTask == false {
                    return req.future(
                        req.redirect(to: "/practice-sessions/\(session.id ?? 0)/result"))
                }

                return try PracticeSession.repository
                    .getCurrent(taskType, for: session, on: req)
                    .flatMap { task in
                        try task.render(session, for: user, on: req)
                            .encode(for: req)
                }
        }
    }

    /// Renders the current task in a `PracticeSession`
    ///
    /// - Parameter req: The http request
    /// - Returns: A rendered `View`
    /// - Throws: If missing any parameters or an internal database error
    func getCurrentMultipleTask(_ req: Request) throws -> Future<Response> {
        return try renderCurrentTask(MultipleChoiseTask.self, on: req)
    }

    /// Renders the current task in a `PracticeSession`
    ///
    /// - Parameter req: The http request
    /// - Returns: A rendered `View`
    /// - Throws: If missing any parameters or an internal database error
    func getCurrentInputTask(_ req: Request) throws -> Future<Response> {
        return try renderCurrentTask(NumberInputTask.self, on: req)
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

                        try PracticeSession.repository
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

                        try PracticeSession.repository
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

                        try PracticeSession.repository
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

                return try PracticeSession.repository
                    .goalProgress(in: session, on: req)
                    .flatMap { progress in

                        try PracticeSession.repository
                            .getResult(for: session, on: req)
                            .map { results in

                                try req.renderer()
                                    .render(
                                        PSResultTemplate.self,
                                        with: .init(
                                            user: user,
                                            tasks: results,
                                            progress: progress,
                                            timeUsed: session.timeUsed ?? results.map { $0.result.timeUsed }.reduce(0, +)
                                        )
                                )
                        }
                }
        }
    }

    /// Returns a session history
    func getSessions(_ req: Request) throws -> Future<HTTPResponse> {

        let user = try req.requireAuthenticated(User.self)

        return try PracticeSession.repository
            .getAllSessions(by: user, on: req)
            .map { sessions in

                try req.renderer()
                    .render(
                        PSHistoryTemplate.self,
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
                try PracticeSession.repository
                    .end(session, for: user, on: req)
                    .transform(to:
                        PracticeSessionEndResponse(sessionResultPath: "/practice-sessions/\(session.id ?? 0)/result")
                )
        }
    }
    
    /// Renders the current task in a `PracticeSession`
    ///
    /// - Parameter req: The http request
    /// - Returns: A rendered `View`
    /// - Throws: If missing any parameters or an internal database error
    func getCurrentFlashCardTask(_ req: Request) throws -> Future<Response> {
        return try renderCurrentTask(FlashCardTask.self, on: req)
    }

    func getAmountHistogram(_ req: Request) throws -> Future<[TaskResult.History]> {

        let user = try req.requireAuthenticated(User.self)

        return req.withPooledConnection(to: .psql) { conn in
            try TaskResultRepository.shared
                .getAmountHistory(for: user, on: conn)
        }
    }
}


extension PSTaskResult: TaskResultable {}

struct PracticeSessionEndResponse: Content {
    let sessionResultPath: String
}
