//
//  TaskResultController.swift
//  App
//
//  Created by Mats Mollestad on 01/04/2019.
//

import Vapor
import FluentPostgreSQL
import KognitaCore


class TaskResultController: RouteCollection {

    func boot(router: Router) throws {
        router.get("results",                       use: getRevisitSchedual)
        router.get("results/topics", Int.parameter, use: getRevisitSchedualFilter)
        router.get("results/overview",              use: getResultsOverview)
    }

    func getRevisitSchedual(_ req: Request) throws -> Future<[TaskResult]> {

        let user = try req.requireAuthenticated(User.self)

        return req.withPooledConnection(to: .psql) { conn in
            try TaskResultRepository.shared
                .getAllResults(for: user.requireID(), with: conn)
        }
    }

    func getRevisitSchedualFilter(_ req: Request) throws -> Future<[TaskResult]> {

        let user = try req.requireAuthenticated(User.self)
        let topicID = try req.parameters.next(Int.self)

        return req.withPooledConnection(to: .psql) { conn in
            try TaskResultRepository.shared
                .getAllResults(for: user.requireID(), filter: \Topic.id == topicID, with: conn)

        }
    }

    func getResultsOverview(on req: Request) throws -> Future<[UserResultOverview]> {
        let user = try req.requireAuthenticated(User.self)
        guard user.isCreator else {
            throw Abort(.forbidden)
        }
        return req.withPooledConnection(to: .psql) { conn in
            TaskResultRepository.shared.getResults(on: conn)
        }
    }
}
