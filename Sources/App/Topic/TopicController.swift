//
//  TopicController.swift
//  App
//
//  Created by Mats Mollestad on 07/10/2018.
//

import FluentPostgreSQL
import Vapor
import KognitaCore

class TopicController: CRUDControllable, RouteCollection {

    static let shared = TopicController()

    func boot(router: Router) {
        router.register(controller: self, at: "topics")
        router.get("subjects", Subject.parameter, "topics", use: getInstanceCollection)
    }

    func getInstanceCollection(_ req: Request) throws -> EventLoopFuture<[Topic]> {

        return try req.parameters
            .next(Subject.self)
            .flatMap { (subject) in

                try TopicRepository.shared
                    .getTopics(in: subject, conn: req)
        }
    }

    func getInstance(_ req: Request) throws -> EventLoopFuture<Topic> {
        return try req.parameters
            .next(Topic.self)
    }

    func edit(_ req: Request) throws -> EventLoopFuture<Topic> {

        let user = try req.requireAuthenticated(User.self)

        return try req.parameters
            .next(Topic.self)
            .flatMap { topic in

                try req.content
                    .decode(TopicCreateContent.self)
                    .flatMap { updatedTopic in

                        try TopicRepository.shared
                            .edit(topic: topic, with: updatedTopic, user: user, on: req)
            }
        }
    }

    func create(_ req: Request) throws -> Future<Topic> {

        let user = try req.requireAuthenticated(User.self)

        return try req.content
            .decode(TopicCreateContent.self)
            .flatMap { topic in

                try TopicRepository.shared
                    .create(with: topic, user: user, conn: req)
            }
    }

    /// Detelets a Topic. Parameter /:Topic
    func delete(_ req: Request) throws -> Future<HTTPStatus> {

        let user = try req.requireAuthenticated(User.self)

        return try req.parameters
            .next(Topic.self)
            .flatMap { topic in

                try TopicRepository.shared
                    .delete(topic: topic, user: user, on: req)
                    .transform(to: .ok)
        }
    }
}
