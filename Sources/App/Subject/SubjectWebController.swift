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
        routes.get("subjects", "search", use: search(on:))

        let subject = routes.grouped("subjects", Subject.parameter)

        subject.get(use: details)
        
        let authRoutes = routes.grouped(RedirectMiddleware<User>(path: "/login"))
        authRoutes.get("subjects", "create", use: createSubject)
        
        let authSubject = authRoutes.grouped("subjects", Subject.parameter)
        authSubject.get("edit", use: editSubject)
        authSubject.get("compendium", use: compendium)
    }

    func search(on req: Request) throws -> EventLoopFuture<View> {

        let query = try req.query.decode(Subject.ListOverview.SearchQuery.self)

        return req.eventLoop.future()
            .flatMap {
                if let user = req.auth.get(User.self) {
                    return req.repositories { repo in
                        repo.subjectRepository
                            .allSubjects(for: user.id, searchQuery: query)
                            
                    }
                } else {
                    return req.repositories { repo in
                        repo.subjectRepository
                            .allSubjects(for: nil, searchQuery: query)
                    }
                }
            }
            .map(Subject.Templates.ListComponent.Context.init(subjects: ))
            .flatMap { context in
                Subject.Templates.ListComponent().render(with: context, for: req)
            }
        
    }

    func listAll(_ req: Request) throws -> EventLoopFuture<View> {

        let query = try? req.query.decode(ListAllQuery.self)
        
        if let user = req.auth.get(User.self) {
            return try req.controllers.taskDiscussionResponseController
                .setRecentlyVisited(on: req) // FIXME: Rename
                .failableFlatMap { activeDiscussion in

                    try req.controllers.subjectController
                        .getListContent(req)
                        .flatMap { listContent in

                            Pages.AuthenticatedDashboard()
                                .render(
                                    with: .init(
                                        user: user,
                                        list: listContent,
                                        wasIncorrectPassword: query?.incorrectPassword ?? false,
                                        recentlyActiveDiscussions: activeDiscussion
                                    ),
                                    for: req
                                )
                       }
            }
        } else {
            return req.repositories { repo  in
                repo.subjectRepository.allSubjects(for: nil, searchQuery: .init())
            }
            .flatMap { subject in
                Pages.UnauthenticatedDashboard()
                    .render(with: .init(subjects: subject, showCoockieMessage: !req.cookies.isAccepted), for: req)
            }
        }
    }

    func details(_ req: Request) throws -> EventLoopFuture<View> {

        return try req.controllers.subjectController
            .getDetails(req)
            .flatMap { details in

                if let user = req.auth.get(User.self) {
                    return Subject.Templates.Details()
                        .render(with: .init(user: user, details: details), for: req)
                } else {
                    return Subject.Templates.Details.Unauthenticated()
                        .render(with: .init(details: details, showCookieMessage: !req.cookies.isAccepted), for: req)
                }
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
