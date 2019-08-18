//
//  SubjectWebController.swift
//  App
//
//  Created by Mats Mollestad on 08/10/2018.
//

import Vapor
import HTMLKit
import KognitaCore
import KognitaViews


final class SubjectWebController: RouteCollection {

    private let controller = SubjectController.shared

    func boot(router: Router) {
        router.get("subjects", use: listAll)
        router.get("subjects/create", use: createSubject)
    }


    func listAll(_ req: Request) throws -> EventLoopFuture<HTTPResponse> {

        let user = try req.requireAuthenticated(User.self)

        return try controller.getInstanceCollection(req).flatMap { subjects in
            req.withPooledConnection(to: .psql) { conn in
                
                try TaskResultRepository.shared
                    .getAllResultsContent(for: user, with: conn)
                    .flatMap { response in

                        try PracticeSessionRepository.shared
                            .getLatestUnfinnishedSessionPath(for: user, on: conn)
                            .map { ongoingSessionPath in

                                try req.renderer()
                                    .render(
                                        SubjectListTemplate.self,
                                        with: .init(
                                            user: user,
                                            cards: subjects,
                                            revisitTasks: response,
                                            ongoingSessionPath: ongoingSessionPath
                                        )
                                )
                        }
                }
            }

        }
    }

    func createSubject(_ req: Request) throws -> HTTPResponse {
        let user = try req.requireAuthenticated(User.self)
        return try req.renderer()
            .render(
                CreateSubjectPage.self,
                with: .init(
                    user: user
                )
        )
    }

    func editSubject(_ req: Request) throws -> Future<HTTPResponse> {

        let user = try req.requireAuthenticated(User.self)

        return try req.parameters
            .next(Subject.self)
            .map { subject in

                return try req.renderer()
                    .render(
                        CreateSubjectPage.self,
                        with: .init(
                            user: user,
                            subjectInfo: subject
                        )
                )
        }
    }
}
