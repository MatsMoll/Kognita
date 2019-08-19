//
//  SubjectController.swift
//  App
//
//  Created by Mats Mollestad on 06/10/2018.
//

import Vapor
import KognitaCore

class SubjectController: CRUDControllable, RouteCollection {

    static let shared = SubjectController()

    func boot(router: Router) {
        router.register(controller: self, at: "subjects")
        router.get("subjects", Subject.parameter, "export", use: export)
        router.get("subjects/export", use: exportAll)
    }

    func getInstanceCollection(_ req: Request) throws -> EventLoopFuture<[Subject]> {
        return SubjectRepository.shared
            .getAll(on: req)
    }

    func getInstance(_ req: Request) throws -> EventLoopFuture<Subject> {
        return try req.parameters.next(Subject.self)
    }

    func create(_ req: Request) throws -> Future<Subject> {

        let user = try req.requireAuthenticated(User.self)

        return try req.content
            .decode(CreateSubjectRequest.self)
            .flatMap { content in

                try SubjectRepository.shared
                    .createSubject(with: content, for: user, conn: req)
        }
    }

    /// Deletes a subject with parameter /:id
    func delete(_ req: Request) throws -> Future<HTTPStatus> {

        let user = try req.requireAuthenticated(User.self)
        return try req.parameters
            .next(Subject.self)
            .flatMap { subject in

            try SubjectRepository.shared
                .delete(subject: subject, user: user, conn: req)
                .transform(to: .ok)
        }
    }

    func edit(_ req: Request) throws -> Future<Subject> {

        let user = try req.requireAuthenticated(User.self)

        return try req.parameters
            .next(Subject.self)
            .flatMap { subject in

                try req.content
                    .decode(CreateSubjectRequest.self)
                    .flatMap { content in

                        try SubjectRepository.shared
                            .edit(subject: subject, with: content, user: user, conn: req)
                }
        }
    }

//    func createTest(_ req: Request) throws -> Future<SubjectTestSet> {
//
//        let user = try req.requireAuthenticated(User.self)
//
//        return try req.parameters.next(Subject.self)
//            .and(req.content.decode(CreateSubjectTest.self))
//            .flatMap { (subject, _) in
//                try SubjectTest.create(for: user, on: subject, with: req)
//            }
//    }

    func export(on req: Request) throws -> Future<SubjectExportContent> {
        _ = try req.requireAuthenticated(User.self)
        return try req.parameters.next(Subject.self).flatMap { subject in
            try TopicRepository.shared
                .exportTopics(in: subject, on: req)
        }
    }

    func exportAll(on req: Request) throws -> Future<[SubjectExportContent]> {
        _ = try req.requireAuthenticated(User.self)
        return SubjectRepository.shared.getAll(on: req)
            .flatMap { subjects in
                try subjects.map { try TopicRepository.shared
                    .exportTopics(in: $0, on: req)
                }
                .flatten(on: req)
        }
    }
}

struct CreateSubjectTest: Content {
    let duration: TimeInterval
}

final class SubjectTestSet: Content {
    var testID: SubjectTest.ID
    var multipleChoises: [MultipleChoiseTask]

    init(test: SubjectTest) throws {
        self.testID = try test.requireID()
        multipleChoises = []
    }
}

struct SubjectTestContent: Content {
    let testID: SubjectTest.ID
    let subject: Subject
    let topics: [Topic]
    let tasks: [Task]
}
