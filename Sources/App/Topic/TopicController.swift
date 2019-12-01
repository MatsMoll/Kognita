//
//  TopicController.swift
//  App
//
//  Created by Mats Mollestad on 07/10/2018.
//

import FluentPostgreSQL
import Vapor
import KognitaCore

final class TopicController: KognitaCRUDControllable, RouteCollection {
    
    typealias Model = Topic
    typealias ResponseContent = Topic

    static let shared = TopicController()

    func boot(router: Router) {
        router.register(controller: self, at: "topics")
        router.get("subjects", Subject.parameter, "topics", use: getAll)
    }
    
    func getAll(_ req: Request) throws -> EventLoopFuture<[Topic]> {
        return try req.parameters
            .next(Subject.self)
            .flatMap { (subject) in

                try Topic.Repository
                    .getTopics(in: subject, conn: req)
        }
    }
}
