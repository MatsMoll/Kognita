//
//  CreatorWebController.swift
//  App
//
//  Created by Mats Mollestad on 27/02/2019.
//

import Vapor
import KognitaCore
import KognitaViews
import QTIKit

final class CreatorWebController: RouteCollection {

    func boot(routes: RoutesBuilder) throws {

        let creator = routes.grouped("creator", "subjects", Subject.parameter)

        creator.get("overview", use: subjectOverview)
        creator.get("search", use: search)
        creator.on(.POST, "import-qti", body: .collect(maxSize: ByteCount(integerLiteral: 1024*8*50)), use: importQTIContent)
    }

    func subjectOverview(_ req: Request) throws -> EventLoopFuture<Response> {
        let user = try req.auth.require(User.self)

        return try req.controllers.subjectController
            .retrive(on: req)
            .flatMap { subject in

                req.repositories.userRepository
                .isModerator(user: user, subjectID: subject.id)
                .flatMap { isModerator in

                    req.repositories.subjectRepository
                        .tasksWith(subjectID: subject.id, user: user, query: nil, maxAmount: nil, withSoftDeleted: isModerator)
                        .failableFlatMap { tasks in

                            try req.repositories.taskSolutionRepository
                                .unverifiedSolutions(in: subject.id, for: user)
                                .flatMapThrowing { solutions in

                                        try req.htmlkit.render(
                                            Subject.Templates.ContentOverview.self,
                                            with: Subject.Templates.ContentOverview.Context(
                                                user: user,
                                                subject: subject,
                                                tasks: tasks,
                                                isModerator: isModerator,
                                                solutions: solutions
                                            )
                                        )
                                }
                        }
                }
        }
    }

    func search(on req: Request) throws -> EventLoopFuture<Response> {

        let user = try req.auth.require(User.self)
        let query = try req.query.decode(TaskOverviewQuery.self)
        let subjectID = try req.parameters.get(Subject.self)

        return req.repositories.userRepository
            .isModerator(user: user, subjectID: subjectID)
            .flatMap { isModerator in

                req.repositories
                    .subjectRepository
                    .tasksWith(subjectID: subjectID, user: user, query: query, maxAmount: nil, withSoftDeleted: isModerator)
                    .flatMapThrowing { tasks in

                        try req.htmlkit.render(
                            Subject.Templates.TaskList.self,
                            with: .init(
                                userID: user.id,
                                isModerator: isModerator,
                                tasks: tasks
                            )
                        )
                }
        }
    }

    struct ImportQTIBody: Decodable {
        let files: [File]
    }

    private func decodeAssessmentItems(from files: [File]) -> [AssessmentItem] {
        var assessmentItems = [AssessmentItem]()
        for file in files {
            guard
                let data = file.data.getData(at: 0, length: file.data.readableBytes),
                let xml = String(data: data, encoding: .utf8),
                let item = try? QTIKit.assessmentItem(withXML: xml)
            else { continue }
            assessmentItems.append(item)
        }
        return assessmentItems
    }

    func importQTIContent(on req: Request) throws -> EventLoopFuture<Response> {

        let user = try req.auth.require(User.self)
        let files = try req.content.decode(ImportQTIBody.self)
        var items = [AssessmentItem]()

        if
            let manifest = files.files.first(where: { $0.filename == "imsmanifest.xml" }),
            let data = manifest.data.getData(at: 0, length: manifest.data.readableBytes),
            let xml = String(data: data, encoding: .utf8) {
            let manifest = try QTIKit.manifest(withXML: xml)

            let assessmentItems = decodeAssessmentItems(from: files.files)
            let itemIDs = Set(assessmentItems.map { $0.id })
            let expectedResources = manifest.resources.map { $0.id }
            let missingResources = expectedResources.filter { itemIDs.contains($0) == false }
            guard missingResources.isEmpty else {
                throw Abort(.badRequest, reason: "Missing some resources with id: \(missingResources)")
            }
            items = assessmentItems
        } else {
            items = decodeAssessmentItems(from: files.files)
        }

        guard items.isEmpty == false else { throw Abort(.badRequest) }

        return try req.repositories.topicRepository
            .topicsWithSubtopics(subjectID: req.parameters.get(Subject.self))
            .map { topics in
                MultipleChoiceTask.Templates.ImportQTI.Context(user: user, tasks: items, topics: topics)
        }
        .flatMapThrowing { context in
            try req.htmlkit.render(MultipleChoiceTask.Templates.ImportQTI.self, with: context)
        }
    }
}
