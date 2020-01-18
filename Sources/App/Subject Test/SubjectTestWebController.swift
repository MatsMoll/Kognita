import Vapor
import KognitaAPI
import KognitaCore

protocol SubjectTestWebControlling: RouteCollection {
    static func enter(on req: Request) throws -> EventLoopFuture<Response>
    static func createForm(on req: Request) throws -> EventLoopFuture<HTTPResponse>
    static func editForm(on req: Request) throws -> EventLoopFuture<HTTPResponse>
    static func listAll(on req: Request) throws -> EventLoopFuture<HTTPResponse>
}

extension SubjectTestWebControlling {
    func boot(router: Router) throws {

        router.get("subjects", Subject.parameter, "subject-tests/create",   use: Self.createForm(on: ))
        router.get("subjects", Subject.parameter, "subject-tests",          use: Self.listAll(on: ))

        let testInstance = router.grouped("subject-tests", SubjectTest.parameter)
        testInstance.post("enter", use: Self.enter(on: ))
        testInstance.get("edit", use: Self.editForm(on: ))
    }
}

class SubjectTestWebController<API: SubjectTestAPIControlling>: SubjectTestWebControlling {

    static func enter(on req: Request) throws -> EventLoopFuture<Response> {
        try API.enter(on: req)
            .map { session in
                try req.redirect(to: "/test-sessions/\(session.requireID())")
        }
    }

    static func createForm(on req: Request) throws -> EventLoopFuture<HTTPResponse> {

        let user = try req.requireAuthenticated(User.self)

        return try req.parameters
            .next(Subject.self)
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
}
