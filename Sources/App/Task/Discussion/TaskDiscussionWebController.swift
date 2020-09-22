import KognitaCore
import KognitaViews
import Vapor

final class TaskDiscussionWebController: RouteCollection {

    func boot(routes: RoutesBuilder) throws {
        routes.get("tasks", GenericTask.parameter, "discussions", use: get(discussions: ))
        routes.get("task-discussions", TaskDiscussion.parameter, "responses", use: getResponses(on: ))
        routes.get("task-discussion", "user", use: getDiscussionsForUser(on: ))
    }

    func get(discussions req: Request) throws -> EventLoopFuture<Response> {

        try req.controllers.taskDiscussionController
            .get(discussions: req)
            .flatMapThrowing { discussions in

                try req.htmlkit.render(
                    TaskDiscussion.Templates.DiscussionCard.self,
                    with: discussions
                )
        }
    }

    func getResponses(on req: Request) throws -> EventLoopFuture<Response> {

        _ = try req.auth.require(User.self)

        return try req.controllers.taskDiscussionResponseController
            .get(responses: req)
            .flatMapThrowing { responses in

                try req.htmlkit.render(
                    TaskPreviewTemplate.Responses.self,
                    with: TaskPreviewTemplate.Responses.Context(
                        responses: responses
                    )
                )
        }
    }

    func getDiscussionsForUser(on req: Request) throws -> EventLoopFuture<Response> {
        let user = try req.auth.require(User.self)

        return try req.controllers.taskDiscussionController
            .getDiscussionsForUser(on: req)
            .flatMapThrowing { discussions in

                return try req.htmlkit
                    .render(
                        TaskDiscussion.Templates.UserDiscussions.self,
                        with: TaskDiscussion.Templates.UserDiscussions.Context(
                            user: user,
                            discussions: discussions
                        )
                )
        }
    }
}
