import KognitaCore
import KognitaViews
import Vapor

final class TaskDiscussionWebController: RouteCollection {

    func boot(router: Router) throws {
        router.get("tasks", Task.parameter, "discussions", use: get(discussions: ))
        router.get("/task-discussions/", TaskDiscussion.parameter, "/responses", use: getResponses(on: ))
        router.get("task-discussion/user", use: getDiscussionsForUser(on: ))
    }

    func get(discussions req: Request) throws -> EventLoopFuture<HTTPResponse> {
        try TaskDiscussion.DefaultAPIController
            .get(discussions: req)
            .map { discussions in

                try req.renderer().render(
                    TaskDiscussion.Templates.DiscussionCard.self,
                    with: discussions
                )
        }
    }

    func getResponses(on req: Request) throws -> EventLoopFuture<HTTPResponse> {
        try TaskDiscussion.Pivot.Response
            .DefaultAPIController
            .get(responses: req)
            .map { responses in

                try req.renderer().render(
                    TaskPreviewTemplate.Responses.self,
                    with: responses
                )
        }
    }

    func getDiscussionsForUser(on req: Request) throws -> EventLoopFuture<HTTPResponse> {
        let user = try req.requireAuthenticated(User.self)

        return try TaskDiscussion.DefaultAPIController
            .getDiscussionsForUser(on: req)
            .map { discussions in

                return try req.renderer()
                    .render(
                        TaskDiscussion.Templates.UserDiscussions.self,
                        with: TaskDiscussion.Templates.UserDiscussions.Context(
                            user: user,
                            discussion: discussions
                        )
                )
        }
    }
}
