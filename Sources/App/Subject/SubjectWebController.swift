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

    func boot(routes: RoutesBuilder) throws {

        routes.get("subjects", use: listAll)
        routes.get("subjects", "create", use: createSubject)
        routes.get("subjects", Subject.parameter, use: details)
        routes.get("subjects", Subject.parameter, "edit", use: editSubject)
        routes.get("subjects", Subject.parameter, "compendium", use: compendium)
    }

    func listAll(_ req: Request) throws -> EventLoopFuture<Response> {

        let user = try req.auth.require(User.self)
        let query = try? req.query.decode(ListAllQuery.self)

        return try req.controllers.taskDiscussionResponseController
            .setRecentlyVisited(on: req) // FIXME: -- Rename
            .failableFlatMap { activeDiscussion in

                try req.controllers.subjectController
                       .getListContent(req)
                       .flatMapThrowing { listContent in

                           try req.htmlkit
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

    func details(_ req: Request) throws -> EventLoopFuture<Response> {

        let user = try req.auth.require(User.self)

        return try req.controllers.subjectController
            .getDetails(req)
            .flatMapThrowing { details in

                try req.htmlkit
                    .render(
                        Subject.Templates.Details.self,
                        with: .init(
                            user: user,
                            details: details
                        )
                )
        }
    }

    func createSubject(_ req: Request) throws -> Response {
        let user = try req.auth.require(User.self)

        guard user.isAdmin else {
            throw Abort(.forbidden)
        }

        return try req.htmlkit
            .render(
                Subject.Templates.Create.self,
                with: .init(
                    user: user
                )
        )
    }

    func editSubject(_ req: Request) throws -> EventLoopFuture<Response> {

        let user = try req.auth.require(User.self)

        return try req.controllers.subjectController
            .retrive(on: req)
            .flatMapThrowing { subject in

                return try req.htmlkit
                    .render(
                        Subject.Templates.Create.self,
                        with: .init(
                            user: user,
                            subjectInfo: subject
                        )
                )
        }
    }

    func compendium(on req: Request) throws -> EventLoopFuture<Response> {

        let user = try req.auth.require(User.self)

        return try req.controllers.subjectController
            .compendium(on: req)
            .flatMapThrowing { compendium in

                try req.htmlkit
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
