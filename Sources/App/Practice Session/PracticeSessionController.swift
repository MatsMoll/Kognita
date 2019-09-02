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

                return req.databaseConnection(to: .psql)
                    .flatMap { conn in
                        
                        try session.currentTask(on: conn)
                            .flatMap { taskContent in
                            
                                try TaskType(content: taskContent)
                                    .render(session, for: user, on: req)
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

struct TaskType: RenderTaskPracticing {
    
    let task: Task
    let multipleChoise: MultipleChoiseTask?
    let numberInputTask: NumberInputTask?
    
    init(content: (task: Task, chosie: MultipleChoiseTask?, input: NumberInputTask?)) {
        self.task = content.task
        self.multipleChoise = content.chosie
        self.numberInputTask = content.input
    }
    
    func render(_ session: PracticeSession, for user: User, on req: Request) throws -> EventLoopFuture<HTTPResponse> {
        
        return try renderableTask
            .render(session, for: user, on: req)
    }
    
    var renderableTask: RenderTaskPracticing {
        switch (multipleChoise, numberInputTask) {
        case (.some(let multiple),   _              ):  return multiple
        case (_,                    .some(let input)):  return input
        default:                                        return FlashCardTask(taskId: task.id)
        }
    }
}
