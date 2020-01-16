//
//  TopicWebController.swift
//  App
//
//  Created by Mats Mollestad on 08/10/2018.
//

import Vapor
import FluentSQL
import KognitaCore
import KognitaViews
import HTMLKit

final class TopicWebController: RouteCollection {

    func boot(router: Router) throws {
        router.get("creator/subjects", Subject.parameter, "topics/create", use: createTopic)
        router.get("creator/subjects", Subject.parameter, "topics", Topic.parameter, "edit", use: editTopic)
    }

    func createTopic(_ req: Request) throws -> Future<HTTPResponse> {

        let user = try req.requireAuthenticated(User.self)

        return try req.parameters
            .next(Subject.self)
            .flatMap { subject in

                try User.DatabaseRepository
                    .isModerator(user: user, subjectID: subject.requireID(), on: req)
                    .map {

                        try req.renderer()
                            .render(
                                Topic.Templates.Create.self,
                                with: .init(
                                    user: user,
                                    subject: subject
                                )
                        )
                }
        }
    }

    func editTopic(_ req: Request) throws -> Future<HTTPResponse> {

        let user = try req.requireAuthenticated(User.self)

        return try req.parameters
            .next(Subject.self)
            .flatMap { subject in

                try User.DatabaseRepository
                    .isModerator(user: user, subjectID: subject.requireID(), on: req)
                    .flatMap {

                        try req.parameters
                            .next(Topic.self)
                            .map { topic in

                                try req.renderer()
                                    .render(
                                        Topic.Templates.Create.self,
                                        with: .init(
                                            user: user,
                                            subject: subject,
                                            topicInfo: topic
                                        )
                                )
                        }
                }
        }
    }
}

struct SubjectSelectTaskPath: Decodable {
    let taskType: String?

    var endPath: String {
        if let taskType = taskType {
            return "/task/\(taskType)/create"
        } else {
            return "/topics/create"
        }
    }
}
