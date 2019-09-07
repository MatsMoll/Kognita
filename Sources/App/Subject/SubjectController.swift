//
//  SubjectController.swift
//  App
//
//  Created by Mats Mollestad on 06/10/2018.
//

import Vapor
import KognitaCore

final class SubjectController: KognitaCRUDControllable, RouteCollection {
    
    typealias Model = Subject
    typealias ResponseContent = Subject

    static let shared = SubjectController()

    func boot(router: Router) {
        router.register(controller: self, at: "subjects")
        router.get("subjects", Subject.parameter, "export", use: export)
        router.get("subjects/export", use: exportAll)
        router.post("subjects/import", use: importContent)
    }
    
    func getAll(_ req: Request) throws -> EventLoopFuture<[Subject]> {
        return Subject.repository
            .all(on: req)
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
            try Topic.Repository.shared
                .exportTopics(in: subject, on: req)
        }
    }

    func exportAll(on req: Request) throws -> Future<[SubjectExportContent]> {
        _ = try req.requireAuthenticated(User.self)
        return Subject.repository
            .all(on: req)
            .flatMap { subjects in
                try subjects.map { try Topic.repository
                    .exportTopics(in: $0, on: req)
                }
                .flatten(on: req)
        }
    }

    func importContent(on req: Request) throws -> Future<Subject> {
        _ = try req.requireAuthenticated(User.self)

        return try req.content
            .decode(SubjectExportContent.self)
            .flatMap {
                Subject.Repository.shared
                    .importContent($0, on: req)
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
