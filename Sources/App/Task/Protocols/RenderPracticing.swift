//
//  RenderPracticing.swift
//  App
//
//  Created by Mats Mollestad on 22/01/2019.
//

import Vapor
import KognitaCore

/// A protocol for a task tha can be practiced on
protocol RenderTaskPracticing {

    /// Render a task in practice mode
    ///
    /// - Parameters:
    ///     - req:      The http request
    ///     - session:  The session object the task is rendered for
    ///     - user:     The user to render the task for
    ///
    /// - Returns:
    ///     A renderd `View` of the task
    func render(in session: PracticeSession, index: Int, for user: User, on req: Request) throws -> Future<HTTPResponse>
}


protocol TaskRenderable {

    /// Render a task in practice mode
    ///
    /// - Parameters:
    ///     - req:      The http request
    ///     - user:     The user to render the task for
    ///
    /// - Returns:
    ///     A renderd `View` of the task
    func render(for user: User, on req: Request) throws -> Future<HTTPResponse>
}


//final class PracticeSessionResult<T: Content>: Content, TaskSubmitResultable {
//
//    var change: Double?
//
//    let unforgivingScore: Double
//
//    let forgivingScore: Double
//
//    var progress: Double
//
//    let result: T
//
//
//    init(result: T, unforgivingScore: Double, forgivingScore: Double, progress: Double, change: Double? = nil) {
//        self.result = result
//        self.unforgivingScore = unforgivingScore
//        self.forgivingScore = forgivingScore
//        self.progress = progress
//        self.change = change
//    }
//}
