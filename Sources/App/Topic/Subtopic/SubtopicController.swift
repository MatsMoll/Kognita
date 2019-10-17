//
//  SubtopicController.swift
//  App
//
//  Created by Mats Mollestad on 26/08/2019.
//

import Vapor
import KognitaCore

final class SubtopicController : KognitaCRUDControllable, RouteCollection {

    typealias Model = Subtopic
    typealias ResponseContent = Subtopic
    
    static let shared = SubtopicController()
    
    func boot(router: Router) throws {
        router.register(controller: self, at: "subtopics")
        router.get(
            "topics", Topic.parameter, "subtopics",
            use: getAll)
    }
    
    func getAll(_ req: Request) throws -> EventLoopFuture<[Subtopic]> {
        return try req.parameters
            .next(Topic.self)
            .flatMap { topic in

                try Subtopic.Repository
                    .getSubtopics(in: topic, with: req)
        }
    }
}
