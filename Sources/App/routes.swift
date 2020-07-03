import Crypto
import Vapor
import KognitaCore
import KognitaViews
import HTMLKit
import KognitaAPI

/// Register your application's routes here.
public func routes(_ app: Application) throws {
    try setupWeb(for: app)
}

private func setupWeb(for app: Application) throws {
    try setupUserWeb(for: app)
}

struct RedirectMiddleware<Auth: Authenticatable>: Middleware {

    let path: String

    func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        if request.auth.get(Auth.self) != nil {
            return next.respond(to: request)
        } else {
            return request.redirect(to: path)
                .encodeResponse(for: request)
        }
    }
}

private func setupUserWeb(for app: Application) throws {

    let sessionMiddle = app.grouped(
        app.sessions.middleware,
        User.sessionAuthMiddleware()
    )
    let redirectMiddle = sessionMiddle.grouped(RedirectMiddleware<User>(path: "/login"))

    sessionMiddle.get { req -> EventLoopFuture<Response> in
        if req.auth.get(User.self) != nil {
            return req.eventLoop.future(req.redirect(to: "/subjects"))
        }
        return try req.htmlkit.render(view: Pages.Landing.self)
            .encodeResponse(for: req)
    }

    app.get("privacy-policy") { req in
        try req.htmlkit.render(view: Pages.PrivacyPolicy.self)
    }
    app.get("terms-of-service") { req in
        try req.htmlkit.render(view: Pages.TermsOfService.self)
    }

    try sessionMiddle.register(collection: UserWebController())
    try redirectMiddle.register(collection: SubjectWebController())
    try redirectMiddle.register(collection: TopicWebController())
    try redirectMiddle.register(collection: MultipleChoiseTaskWebController())
    try redirectMiddle.register(collection: CreatorWebController())
    try redirectMiddle.register(collection: FlashCardTaskWebController())
    try redirectMiddle.register(collection: SubtopicWebController())
    try redirectMiddle.register(collection: PracticeSessionWebController())
    try redirectMiddle.register(collection: SubjectTestWebController())
    try redirectMiddle.register(collection: TestSessionWebController())
    try redirectMiddle.register(collection: TaskDiscussionWebController())
}
