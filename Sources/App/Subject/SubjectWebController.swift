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

    private struct ListAllQuery: Codable {
        let incorrectPassword: Bool
    }


    func boot(router: Router) {
        router.get("subjects", use: listAll)
        router.get("subjects/create", use: createSubject)
        router.get("subjects", Subject.parameter, use: details)
        router.get("subjects", Subject.parameter, "compendium", use: compendium)
    }


    func listAll(_ req: Request) throws -> EventLoopFuture<HTTPResponse> {

        let user = try req.requireAuthenticated(User.self)
        let query = try? req.query.decode(ListAllQuery.self)

        return try TaskDiscussion.Pivot.Response.DefaultAPIController
            .setRecentlyVisited(for: user, on: req)
            .flatMap { activeDiscussion in

            try Subject.DefaultAPIController
                       .getListContent(req)
                       .map { listContent in

                           try req.renderer()
                               .render(
                                   Subject.Templates.ListOverview.self,
                                   with: .init(
                                       user: user,
                                       list: listContent,
                                       wasIncorrectPassword: query?.incorrectPassword ?? false,
                                       recentlyActiveDiscussions: activeDiscussion
                                   )
                           )
                   }
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
        
        guard user.isAdmin else {
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

        return req.parameters
            .model(Subject.self, on: req)
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

    func compendium(on req: Request) throws -> EventLoopFuture<HTTPResponse> {

        let user = try req.requireAuthenticated(User.self)

        return try Subject.DefaultAPIController
            .compendium(on: req)
            .map { compendium in

                try req.renderer()
                    .render(
                        Subject.Templates.Compendium.self,
                        with: .init(
                            user: user,
                            compendium: compendium
                        )
                )
        }
    }
}
