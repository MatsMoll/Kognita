
import Vapor
import KognitaCore
import KognitaAPI
import KognitaViews

protocol TestSessionWebControlling: RouteCollection {
    func redirectToTask(on req: Request) throws -> EventLoopFuture<Response>
    func taskWithID(on req: Request) throws -> EventLoopFuture<HTTPResponse>
}

extension TestSessionWebControlling {

    func boot(router: Router) throws {

        let sessionInstance = router.grouped("test-sessions", TaskSession.TestParameter.parameter)

        sessionInstance.get("/", use: self.redirectToTask(on: ))
        sessionInstance.get("tasks", Int.parameter, use: self.taskWithID(on: ))
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
}
