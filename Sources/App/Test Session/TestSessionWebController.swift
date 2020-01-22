
import Vapor
import KognitaCore
import KognitaAPI
import KognitaViews

protocol TestSessionWebControlling: RouteCollection {
    func redirectToTask(on req: Request) throws -> EventLoopFuture<Response>
    func taskWithID(on req: Request) throws -> EventLoopFuture<HTTPResponse>
    func overview(on req: Request) throws -> EventLoopFuture<HTTPResponse>
    func finnish(on req: Request) throws -> EventLoopFuture<Response>
    func results(on req: Request) throws -> EventLoopFuture<HTTPResponse>
}

extension TestSessionWebControlling {

    func boot(router: Router) throws {

        let sessionInstance = router.grouped("test-sessions", TaskSession.TestParameter.parameter)

        sessionInstance.get("/",                    use: self.redirectToTask(on: ))
        sessionInstance.get("tasks", Int.parameter, use: self.taskWithID(on: ))
        sessionInstance.get("tasks/overview",       use: self.overview(on: ))
        sessionInstance.get("results",              use: self.results(on: ))
        sessionInstance.post("finnish",             use: self.finnish(on: ))
    }
}


class TestSessionWebController: TestSessionWebControlling {

    func redirectToTask(on req: Request) throws -> EventLoopFuture<Response> {

        return try req.parameters
            .next(TaskSession.TestParameter.self)
            .flatMap { session in

                try SubjectTest.DatabaseRepository
                    .firstTaskID(testID: session.testID, on: req)
                    .map { id in
                        try req.redirect(to: "/test-sessions/\(session.requireID())/tasks/\(id ?? 0)")
                }
        }
    }

    func taskWithID(on req: Request) throws -> EventLoopFuture<HTTPResponse> {

        let user = try req.requireAuthenticated(User.self)

        return try req.parameters
            .next(TaskSession.TestParameter.self)
            .flatMap { session in

                let taskID = try req.parameters.next(Int.self)

                return try SubjectTest.DatabaseRepository
                    .taskWith(id: taskID, in: session, for: user, on: req)
                    .map { task in

                        try req.renderer()
                            .render(
                                MultipleChoiseTaskTestMode.self,
                                with: MultipleChoiseTaskTestMode.Context(
                                    user: user,
                                    task: task
                                )
                        )

                }
        }
    }

    func overview(on req: Request) throws -> EventLoopFuture<HTTPResponse> {

        let user = try req.requireAuthenticated(User.self)

        return try TestSession.DefaultAPIController
            .overview(on: req)
            .map { overview in

                return try req.renderer()
                    .render(
                        TestSession.Templates.Overview.self,
                        with: TestSession.Templates.Overview.Context(
                            user: user,
                            overview: overview
                        )
                )
        }
    }

    func finnish(on req: Request) throws -> EventLoopFuture<Response> {

        guard
            let testSessionIDRaw = req.parameters.rawValues(for: TaskSession.TestParameter.self).first,
            let testSessionID = Int(testSessionIDRaw)
        else {
            throw Abort(.badRequest)
        }

        return try TestSession.DefaultAPIController
            .submit(test: req)
            .map { _ in
                req.redirect(to: "/test-sessions/\(testSessionID)/results")
        }
    }

    func results(on req: Request) throws -> EventLoopFuture<HTTPResponse> {

        let user = try req.requireAuthenticated(User.self)

        return try TestSession.DefaultAPIController
            .results(on: req)
            .map { results in

                try req.renderer()
                    .render(
                        TestSession.Templates.Results.self,
                        with: TestSession.Templates.Results.Context(
                            user: user,
                            results: results
                        )
                )
        }
    }
}
