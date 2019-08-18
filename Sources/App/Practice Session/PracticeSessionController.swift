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

final class PracticeSessionController: RouteCollection {

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

    static let shared = PracticeSessionController()

    /// Creates a new session
    ///
    /// - Requires:
    ///     A subject code in the url ".../**Some Subject Code**/...",
    ///
    /// - Parameter req:
    ///     The http request containing a `PracticeSessionCreateContent` body
    ///
    /// - Throws:
    ///     - If unauthorized
    ///     - Missing or invalid url parameter
    ///     - Missing or invalid `PracticeSessionCreateContent` content
    ///
    /// - Returns:
    ///     A `PracticeSessionCreateResponse` struct
    func create(_ req: Request) throws -> Future<PracticeSessionCreateResponse> {

        let user = try req.requireAuthenticated(User.self)

        return try req.content
            .decode(PracticeSessionCreateContent.self)
            .flatMap { content in
                PracticeSessionRepository.shared
                    .create(for: user, with: content, on: req)
        }
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

                return try PracticeSessionRepository.shared
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
    func submitMultipleTaskAnswer(_ req: Request) throws -> Future<PracticeSessionResult<[MultipleChoiseTaskChoiseResult]>> {

        let user = try req.requireAuthenticated(User.self)

        return try req.content
            .decode(MultipleChoiseTaskSubmit.self)
            .flatMap { submit in

                try req.parameters
                    .next(PracticeSession.self)
                    .flatMap { (session) in

                        try PracticeSessionRepository.shared
                            .submitMultipleChoise(submit, in: session, by: user, on: req)
                }
        }
    }

    /// Submits an answer to a session
    ///
    /// - Parameter req: The http request
    /// - Returns: A response containing the result
    /// - Throws: if unautorized, database errors ext.
    func submitInputTaskAnswer(_ req: Request) throws -> Future<PracticeSessionResult<NumberInputTaskSubmitResponse>> {

        let user = try req.requireAuthenticated(User.self)

        return try req.content
            .decode(NumberInputTaskSubmit.self)
            .flatMap { submit in

                try req.parameters
                    .next(PracticeSession.self)
                    .flatMap { session in

                        try PracticeSessionRepository.shared
                            .submitInputTask(submit, in: session, by: user, on: req)
                }
        }
    }


    func submitFlashCardKnowledge(_ req: Request) throws -> Future<PracticeSessionResult<FlashCardTaskSubmit>> {

        let user = try req.requireAuthenticated(User.self)

        return try req.content
            .decode(FlashCardTaskSubmit.self)
            .flatMap { submit in

                try req.parameters
                    .next(PracticeSession.self)
                    .flatMap { session in

                        try PracticeSessionRepository.shared
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

                return try PracticeSessionRepository.shared
                    .goalProgress(in: session, on: req)
                    .flatMap { progress in

                        try PracticeSessionRepository.shared
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

        return try PracticeSessionRepository.shared
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
                try PracticeSessionRepository.shared
                    .end(session, for: user, on: req)
                    .transform(to:
                        PracticeSessionEndResponse(sessionResultPath: "/practice-sessions/\(session.id ?? 0)/result")
                )
        }
    }
//
//    /// Returns the result of a given session and task
//    ///
//    /// - Parameter req: The HTTP-request
//    /// - Returns: A view displaying the result
//    /// - Throws: Misformd data etc.
//    func getMultupleTaskResult(_ req: Request) throws -> Future<HTTPResponse> {
//
//        let user = try req.requireAuthenticated(User.self)
//
//        return try req.parameters.next(PracticeSession.self).flatMap { session in
//            try req.parameters.next(MultipleChoiseTask.self).flatMap { multiple in
//                guard let task = multiple.task else {
//                    throw Abort(.internalServerError)
//                }
//                return task.get(on: req).flatMap { task in
//                    try multiple.content(on: req).flatMap { content in
//                        Topic.find(task.topicId, on: req)
//                            .unwrap(or: Abort(.internalServerError))
//                            .flatMap { topic in
//                                topic.subject.get(on: req).map { subject in
//
//                                    let preview = TaskPreviewContent(
//                                        subject: subject,
//                                        topic: topic,
//                                        task: task,
//                                        actionDescription: multiple.actionDescription
//                                    )
//                                    return try req.renderer()
//                                        .render(
//                                            MultipleChoiseTaskTemplate.self,
//                                            with: .init(
//                                                multiple: content,
//                                                taskContent: preview,
//                                                user: user
//                                            )
//                                    )
//                                }
//                        }
//                    }
//                }
//            }
//        }
//    }
//
    /// Renders the current task in a `PracticeSession`
    ///
    /// - Parameter req: The http request
    /// - Returns: A rendered `View`
    /// - Throws: If missing any parameters or an internal database error
    func getCurrentFlashCardTask(_ req: Request) throws -> Future<Response> {
        return try renderCurrentTask(FlashCardTask.self, on: req)
    }

    func getAmountHistogram(_ req: Request) throws -> Future<[TaskResultHistory]> {

        let user = try req.requireAuthenticated(User.self)

        return req.withPooledConnection(to: .psql) { conn in
            try TaskResultRepository.shared
                .getAmountHistory(for: user, on: conn)
        }
    }
}

//struct PracticeSessionHistory: Content {
//
//    let timePracticed: TimeInterval
//
//    let date: Date
//}
//
///// The content needed to create a session
//class PracticeSessionCreateContent: Decodable {
//
//    /// The number of task to complete in a session
//    let numberOfTaskGoal: Int
//
//    /// The topic id's for the tasks to map
//    let topicIDs: [Topic.ID]
//}
//
///// The response when creating a new session
//final class PracticeSessionCreateResponse: Content {
//
//    /// A redirection to the session
//    let redirectionUrl: String
//
//    init(redirectionUrl: String) {
//        self.redirectionUrl = redirectionUrl
//    }
//}


extension PSTaskResult: TaskResultable {}


struct PracticeSessionEndResponse: Content {
    let sessionResultPath: String
}
