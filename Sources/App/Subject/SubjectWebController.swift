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
import KognitaAPI

final class SubjectWebController: RouteCollection {

    func boot(router: Router) {
        router.get("subjects", use: listAll)
        router.get("subjects/create", use: createSubject)
        router.get("subjects", Subject.parameter, use: details)
    }


    func listAll(_ req: Request) throws -> EventLoopFuture<HTTPResponse> {

        let user = try req.requireAuthenticated(User.self)

        return try Subject.DefaultAPIController
            .retriveAll(on: req)
            .flatMap { subjects in

//                try TaskResult.DatabaseRepository
//                    .getAllResults(for: user.requireID(), with: req)
//                    .flatMap { response in

                        try PracticeSession.DatabaseRepository
                            .getLatestUnfinnishedSessionPath(for: user, on: req)
                            .map { ongoingSessionPath in

                                try req.renderer()
                                   .render(
                                       Subject.Templates.ListOverview.self,
                                       with: .init(
                                           user: user,
                                           cards: subjects,
                                           revisitTasks: [],
                                           ongoingSessionPath: ongoingSessionPath
                                       )
                               )

                        }
//                }
        }
    }


    func details(_ req: Request) throws -> EventLoopFuture<HTTPResponse> {

        let user = try req.requireAuthenticated(User.self)

        return try Subject.DefaultAPIController
            .getDetails(req)
            .map { details in

                try req.renderer()
                    .render(
                        Subject.Templates.Details.self,
                        with: .init(
                            user: user,
                            details: details
                        )
                )
        }
    }


    func createSubject(_ req: Request) throws -> HTTPResponse {
        let user = try req.requireAuthenticated(User.self)
        
        guard user.isCreator else {
            throw Abort(.forbidden)
        }

        return try req.renderer()
            .render(
                Subject.Templates.Create.self,
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
                        Subject.Templates.Create.self,
                        with: .init(
                            user: user,
                            subjectInfo: subject
                        )
                )
        }
    }
}
