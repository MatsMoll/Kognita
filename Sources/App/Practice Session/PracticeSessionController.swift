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

    struct HistogramQuery: Codable {
        let numberOfWeeks: Int?
        let subjectId: Subject.ID?
    }

    func getAmountHistogram(_ req: Request) throws -> EventLoopFuture<[TaskResult.History]> {

        let user = try req.requireAuthenticated(User.self)

        let query = try req.query.decode(HistogramQuery.self)
        return req.withPooledConnection(to: .psql) { conn in
            if let subjectId = query.subjectId {
                return try TaskResultRepository
                    .getAmountHistory(for: user, in: subjectId, on: conn, numberOfWeeks: query.numberOfWeeks ?? 4)
            } else {
                return try TaskResultRepository
                    .getAmountHistory(for: user, on: conn, numberOfWeeks: query.numberOfWeeks ?? 4)
            }
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
