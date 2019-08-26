//
//  SubtopicController.swift
//  App
//
//  Created by Mats Mollestad on 26/08/2019.
//

import Vapor
import KognitaCore

class SubtopicController : CRUDControllable, RouteCollection {

    func boot(router: Router) throws {
        router.register(
            controller: self,
            at: "subtopics")
        router.get(
            "topics", Topic.parameter, "subtopics",
            use: getInstanceCollection)
    }

    func getInstanceCollection(_ req: Request) throws -> EventLoopFuture<[Subtopic]> {
        return try req.parameters
            .next(Topic.self)
            .flatMap { topic in

                try SubtopicRepository.shared
                    .getSubtopics(in: topic, with: req)
        }
    }

    func getInstance(_ req: Request) throws -> EventLoopFuture<Subtopic> {
        return try req.parameters
            .next(Subtopic.self)
    }

    func create(_ req: Request) throws -> EventLoopFuture<Subtopic> {

        let user = try req.requireAuthenticated(User.self)

        return try req.content
            .decode(Subtopic.Create.Data.self)
            .flatMap { content in

                try SubtopicRepository.shared
                    .create(from: content, user: user, with: req)
        }
    }

    func delete(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {

        let user = try req.requireAuthenticated(User.self)

        return try req.parameters
            .next(Subtopic.self)
            .flatMap { subtopic in

                try SubtopicRepository.shared
                    .delete(subtopic, user: user, with: req)
                    .transform(to: .ok)
        }
    }

    func edit(_ req: Request) throws -> EventLoopFuture<Subtopic> {

        let user = try req.requireAuthenticated(User.self)

        return try req.parameters
            .next(Subtopic.self)
            .flatMap { subtopic in

                try req.content
                    .decode(Subtopic.Edit.Data.self)
                    .flatMap { content in

                        try SubtopicRepository.shared
                            .edit(subtopic, with: content, user: user, conn: req)
                }
        }
    }
}
