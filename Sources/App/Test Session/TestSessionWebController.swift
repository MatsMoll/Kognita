import Vapor
import KognitaCore
import KognitaAPI
import KognitaViews

protocol TestSessionWebControlling: RouteCollection {
    func redirectToTask(on req: Request) throws -> EventLoopFuture<Response>
    func taskWithID(on req: Request) throws -> EventLoopFuture<Response>
    func overview(on req: Request) throws -> EventLoopFuture<Response>
    func finnish(on req: Request) throws -> EventLoopFuture<Response>
    func results(on req: Request) throws -> EventLoopFuture<Response>
    func detailedResult(on req: Request) throws -> EventLoopFuture<Response>
    func solutions(on req: Request) throws -> EventLoopFuture<Response>
}

extension TestSessionWebControlling {

    func boot(routes: RoutesBuilder) throws {

        let sessionInstance = routes.grouped("test-sessions", TestSession.parameter)

        sessionInstance.get(use: self.redirectToTask(on: ))
        sessionInstance.get("tasks", Int.parameter, use: self.taskWithID(on: ))
        sessionInstance.get("tasks", Int.parameter, "solutions", use: self.solutions(on: ))
        sessionInstance.get("tasks", "overview", use: self.overview(on: ))
        sessionInstance.get("results", use: self.results(on: ))
        sessionInstance.get("tasks", Int.parameter, "result", use: self.detailedResult(on: ))
        sessionInstance.post("finnish", use: self.finnish(on: ))
    }
}

class TestSessionWebController: TestSessionWebControlling {

    func redirectToTask(on req: Request) throws -> EventLoopFuture<Response> {

        let sessionID = try req.parameters.get(TestSession.self)

        return req.repositories { repositories in
            return repositories.testSessionRepository
                .testIDFor(id: sessionID)
                .failableFlatMap { testID in
                    try repositories.subjectTestRepository
                        .firstTaskID(testID: testID)
                        .map { id in
                            req.redirect(to: "/test-sessions/\(sessionID)/tasks/\(id ?? 0)")
                    }
            }
        }
    }

    func taskWithID(on req: Request) throws -> EventLoopFuture<Response> {

        let user = try req.auth.require(User.self)

        return req.repositories { repositories in
            return try repositories.testSessionRepository
                .sessionReporesentableWith(id: req.parameters.get(TestSession.self))
                .failableFlatMap { session in

                    let taskID = try req.parameters.get(Int.self)

                    return try repositories.subjectTestRepository
                        .taskWith(id: taskID, in: session, for: user)
                        .flatMapThrowing { task in

                            try req.htmlkit
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
    }

    func overview(on req: Request) throws -> EventLoopFuture<Response> {

        let user = try req.auth.require(User.self)

        return try req.controllers.testSessionController
            .overview(on: req)
            .flatMapThrowing { overview in

                return try req.htmlkit
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

        let sessionID = try req.parameters.get(TestSession.self)

        return try req.controllers.testSessionController
            .submit(test: req)
            .map { _ in
                req.redirect(to: "/test-sessions/\(sessionID)/results")
        }
    }

    func results(on req: Request) throws -> EventLoopFuture<Response> {

        let user = try req.auth.require(User.self)

        return try req.controllers.testSessionController
            .results(on: req)
            .flatMapThrowing { results in

                try req.htmlkit
                    .render(
                        TestSession.Templates.Results.self,
                        with: TestSession.Templates.Results.Context(
                            user: user,
                            results: results
                        )
                )
        }
    }

    func solutions(on req: Request) throws -> EventLoopFuture<Response> {

        let user = try req.auth.require(User.self)

        return try req.controllers.testSessionController
            .solutions(on: req)
            .flatMapThrowing { solutions in

                try req.htmlkit
                    .render(
                        TaskSolution.Templates.List.self,
                        with: .init(
                            user: user,
                            solutionResources: TaskSolution.Resources(solutions: solutions, resources: [])
                        )
                )
        }
    }

    func detailedResult(on req: Request) throws -> EventLoopFuture<Response> {

        let user = try req.auth.require(User.self)

        return try req.controllers.testSessionController
            .detailedTaskResult(on: req)
            .failableFlatMap { result in

                try req.htmlkit.render(
                    TestSession.Templates.TaskResult.self,
                    with: .init(
                        user: user,
                        result: result
                    )
                )
                .encodeResponse(for: req)
        }
        .flatMapErrorThrowing { error in
            switch error {
            case TestSessionRepositoringError.testIsNotFinnished:
                guard let sessionID = try? req.parameters.get(TestSession.self) else { throw Abort(.internalServerError) }
                return req.redirect(to: "/test-sessions/\(sessionID)/results")
            default: throw error
            }
        }
    }
}
