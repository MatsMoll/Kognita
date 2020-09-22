import Vapor
import KognitaAPI
import KognitaCore

protocol SubjectTestWebControlling: RouteCollection {
    static func enter(on req: Request) throws -> EventLoopFuture<Response>
    static func createForm(on req: Request) throws -> EventLoopFuture<Response>
    static func editForm(on req: Request) throws -> EventLoopFuture<Response>
    static func listAll(on req: Request) throws -> EventLoopFuture<Response>
    static func monitor(on req: Request) throws -> EventLoopFuture<Response>
    static func status(on req: Request) throws -> EventLoopFuture<Response>
    static func end(on req: Request) throws -> EventLoopFuture<Response>
    static func results(on req: Request) throws -> EventLoopFuture<Response>
}

extension SubjectTestWebControlling {
    func boot(routes: RoutesBuilder) throws {

        routes.get("subjects", Subject.parameter, "subject-tests", "create", use: Self.createForm(on: ))
        routes.get("subjects", Subject.parameter, "subject-tests", use: Self.listAll(on: ))

        let testInstance = routes.grouped("subject-tests", SubjectTest.parameter)

        testInstance.post("enter", use: Self.enter(on: ))

        testInstance.get("edit", use: Self.editForm(on: ))
        testInstance.get("monitor", use: Self.monitor(on: ))
        testInstance.get("status", use: Self.status(on: ))
        testInstance.get("results", use: Self.results(on: ))

        testInstance.post("end", use: Self.end(on: ))
    }
}

class SubjectTestWebController: SubjectTestWebControlling {

    static func enter(on req: Request) throws -> EventLoopFuture<Response> {

        try req.controllers.subjectTestController
            .end(req: req)
            .flatMapThrowing { _ in
                try req.redirect(to: "/test-sessions/\(req.parameters.get(SubjectTest.self))")
        }
        .flatMapErrorThrowing { error in
            switch error {
            case SubjectTest.DatabaseRepository.Errors
                .alreadyEntered(sessionID: let sessionID):
                return req.redirect(to: "/test-sessions/\(sessionID)")
            case SubjectTest.DatabaseRepository.Errors
                .incorrectPassword:
                return req.redirect(to: "/subjects?incorrectPassword=true")
            default:
                throw error
            }
        }
    }

    static func createForm(on req: Request) throws -> EventLoopFuture<Response> {

        let user = try req.auth.require(User.self)

        let subjectID = try req.parameters.get(Subject.self)

        return req.repositories.subjectRepository
            .tasksWith(subjectID: subjectID)
            .flatMapThrowing { tasks in

                try req.htmlkit
                    .render(
                        SubjectTest.Templates.Modify.self,
                        with: SubjectTest.Templates.Modify.Context(
                            subjectID: subjectID,
                            user: user,
                            tasks: tasks
                        )
                )
        }
    }

    static func editForm(on req: Request) throws -> EventLoopFuture<Response> {

        let user = try req.auth.require(User.self)

        return try req.controllers.subjectTestController
            .modifyContent(for: req)
            .failableFlatMap { test in

                req.repositories.subjectRepository
                    .tasksWith(subjectID: test.subjectID)
                    .flatMapThrowing { tasks in

                        try req.htmlkit
                            .render(
                                SubjectTest.Templates.Modify.self,
                                with: SubjectTest.Templates.Modify.Context(
                                    subjectID: req.parameters.get(Subject.self),
                                    user: user,
                                    tasks: tasks,
                                    test: test
                                )
                        )
                }
        }
    }

    static func listAll(on req: Request) throws -> EventLoopFuture<Response> {

        let user = try req.auth.require(User.self)

        return try req.controllers.subjectTestController
            .allInSubject(on: req)
            .flatMapThrowing { list in

                try req.htmlkit
                    .render(
                        SubjectTest.Templates.List.self,
                        with: .init(
                            user: user,
                            list: list
                        )
                )
        }
    }

    static func monitor(on req: Request) throws -> EventLoopFuture<Response> {

        let user = try req.auth.require(User.self)

        return req.controllers.subjectTestController
            .test(withID: req)
            .flatMap { test in

                req.repositories.userRepository
                    .isModerator(user: user, subjectID: test.subjectID)
                    .ifFalse(throw: Abort(.forbidden))
                    .flatMapThrowing {

                        try req.htmlkit
                            .render(
                                SubjectTest.Templates.Monitor.self,
                                with: SubjectTest.Templates.Monitor.Context(
                                    user: user,
                                    test: test
                                )
                        )
                }
        }
    }

    static func status(on req: Request) throws -> EventLoopFuture<Response> {

        return try req.controllers.subjectTestController
            .userCompletionStatus(on: req)
            .flatMapThrowing { status in

                try req.htmlkit
                    .render(
                        SubjectTest.Templates.StatusSection.self,
                        with: status
                )
        }
    }

    static func end(on req: Request) throws -> EventLoopFuture<Response> {

        try req.controllers.subjectTestController
            .end(req: req)
            .map { _ in
                req.redirect(to: "results")
        }
        .flatMapErrorThrowing { error in
            switch error {
            case SubjectTest.DatabaseRepository.Errors.alreadyEnded: return req.redirect(to: "results")
            default: throw error
            }
        }
    }

    static func results(on req: Request) throws -> EventLoopFuture<Response> {

        let user = try req.auth.require(User.self)

        return try req.controllers.subjectTestController
            .results(on: req)
            .flatMapThrowing { results in

                try req.htmlkit
                    .render(
                        SubjectTest.Templates.Results.self,
                        with: SubjectTest.Templates.Results.Context(
                            user: user,
                            results: results
                        )
                )
        }
    }
}
