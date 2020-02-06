import Vapor
import KognitaAPI
import KognitaCore

protocol SubjectTestWebControlling: RouteCollection {
    static func enter(on req: Request) throws -> EventLoopFuture<Response>
    static func createForm(on req: Request) throws -> EventLoopFuture<HTTPResponse>
    static func editForm(on req: Request) throws -> EventLoopFuture<HTTPResponse>
    static func listAll(on req: Request) throws -> EventLoopFuture<HTTPResponse>
    static func monitor(on req: Request) throws -> EventLoopFuture<HTTPResponse>
    static func status(on req: Request) throws -> EventLoopFuture<HTTPResponse>
    static func end(on req: Request) throws -> EventLoopFuture<Response>
    static func results(on req: Request) throws -> EventLoopFuture<HTTPResponse>
}

extension SubjectTestWebControlling {
    func boot(router: Router) throws {

        router.get("subjects", Subject.parameter, "subject-tests/create",   use: Self.createForm(on: ))
        router.get("subjects", Subject.parameter, "subject-tests",          use: Self.listAll(on: ))

        let testInstance = router.grouped("subject-tests", SubjectTest.parameter)

        testInstance.post("enter", use: Self.enter(on: ))

        testInstance.get("edit",    use: Self.editForm(on: ))
        testInstance.get("monitor", use: Self.monitor(on: ))
        testInstance.get("status",  use: Self.status(on: ))
        testInstance.get("results", use: Self.results(on: ))

        testInstance.post("end",    use: Self.end(on: ))
    }
}

class SubjectTestWebController<API: SubjectTestAPIControlling>: SubjectTestWebControlling {

    static func enter(on req: Request) throws -> EventLoopFuture<Response> {
        try API.enter(on: req)
            .map { session in
                try req.redirect(to: "/test-sessions/\(session.requireID())")
        }
        .catchMap { error in
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

    static func createForm(on req: Request) throws -> EventLoopFuture<HTTPResponse> {

        let user = try req.requireAuthenticated(User.self)

        return req.parameters
            .model(Subject.self, on: req)
            .flatMap { subject in

                try User.DatabaseRepository
                    .isModerator(user: user, subjectID: subject.requireID(), on: req)
                    .flatMap {

                        try Task.Repository
                            .examTasks(subjectID: subject.requireID(), on: req)
                            .map { tasks in

                                try req.renderer()
                                    .render(
                                        SubjectTest.Templates.Modify.self,
                                        with: SubjectTest.Templates.Modify.Context(
                                            user: user,
                                            tasks: tasks
                                        )
                                )
                        }
                }
        }
    }

    static func editForm(on req: Request) throws -> EventLoopFuture<HTTPResponse> {

        let user = try req.requireAuthenticated(User.self)

        return try API.test(withID: req)
            .flatMap { test in

                try User.DatabaseRepository
                    .isModerator(user: user, subjectID: test.subjectID, on: req)
                    .flatMap {

                        Task.Repository
                               .examTasks(subjectID: test.subjectID, on: req)
                               .map { tasks in

                                   try req.renderer()
                                       .render(
                                           SubjectTest.Templates.Modify.self,
                                           with: SubjectTest.Templates.Modify.Context(
                                               user: user,
                                               tasks: tasks,
                                               test: test
                                           )
                                   )
                           }
                }
        }
    }

    static func listAll(on req: Request) throws -> EventLoopFuture<HTTPResponse> {

        let user = try req.requireAuthenticated(User.self)

        return try API.allInSubject(on: req)
            .map { list in

                try req.renderer()
                    .render(
                        SubjectTest.Templates.List.self,
                        with: .init(
                            user: user,
                            list: list
                        )
                )
        }
    }

    static func monitor(on req: Request) throws -> EventLoopFuture<HTTPResponse> {

        let user = try req.requireAuthenticated(User.self)

        return req.parameters
            .model(SubjectTest.self, on: req)
            .map { test in

                try req.renderer()
                    .render(
                        SubjectTest.Templates.Monitor.self,
                        with: SubjectTest.Templates.Monitor.Context(
                            user: user,
                            test: test
                        )
                )
        }
    }

    static func status(on req: Request) throws -> EventLoopFuture<HTTPResponse> {

        return try API.userCompletionStatus(on: req)
            .map { status in

                try req.renderer()
                    .render(
                        SubjectTest.Templates.StatusSection.self,
                        with: status
                )
        }
    }

    static func end(on req: Request) throws -> EventLoopFuture<Response> {

        try API.end(req: req)
            .map { _ in
                req.redirect(to: "results")
        }
    }

    static func results(on req: Request) throws -> EventLoopFuture<HTTPResponse> {

        let user = try req.requireAuthenticated(User.self)

        return try API.results(on: req)
            .map { results in

                try req.renderer()
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
