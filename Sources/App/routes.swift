import Crypto
import Vapor
import Authentication
import KognitaCore
import KognitaViews
import HTMLKit

//extension HTMLRenderable {
//
//    /// Renders a `StaticView` formula
//    ///
//    ///     try renderer.render(WelcomeView.self)
//    ///
//    /// - Parameter type: The view type to render
//    /// - Returns: Returns a rendered view in a `Response`
//    /// - Throws: If the formula do not exists, or if the rendering process fails
//    public func render<T: TemplateView>(_ type: T.Type, with value: T.Value) throws -> HTTPResponse {
//        try HTTPResponse(headers: .init([("content-type", "text/html; charset=utf-8")]), body: renderRaw(type, with: value))
//    }
//
//    public func render<T: StaticView>(_ type: T.Type) throws -> HTTPResponse {
//        try HTTPResponse(headers: .init([("content-type", "text/html; charset=utf-8")]), body: renderRaw(type))
//    }
//}

//extension HTMLRenderer: Service {}

/// A provider for the HTMLKit Library
//public final class HTMLKitProvider: Provider {
//
//    public init() {}
//
//    // View `Provider` protocol
//    public func register(_ services: inout Services) throws {
//
//        services.register(HTMLRenderable.self) { (container) in
//            return try container.make(HTMLRenderer.self)
//        }
//    }
//
//    // View `Provider` protocol
//    public func didBoot(_ container: Container) throws -> EventLoopFuture<Void> {
//        return .done(on: container)
//    }
//}
//
//extension Request {
//
//    /// Creates a `HTMLRenderer` that can render templates
//    ///
//    /// - Returns: A `HTMLRenderer` containing all the templates
//    /// - Throws: If the shared container could not make the `HTMLRenderer`
//    public func renderer() throws -> HTMLRenderable {
//        return try sharedContainer.make(HTMLRenderable.self)
//    }
//}

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    try setupApi(for: router.grouped("api"))
    try setupWeb(for: router)
}

private func setupWeb(for route: Router) throws {
    try setupUserWeb(for: route)
}

private func setupUserWeb(for router: Router) throws {

    let sessionMiddle = router.grouped(User.authSessionsMiddleware())
    let redirectMiddle = sessionMiddle.grouped(RedirectMiddleware<User>(path: "/login"))

    router.get("/") { req in
        try req.renderer().render(view: Pages.Landing.self)
    }

    try sessionMiddle.register(collection: UserWebController())
    try redirectMiddle.register(collection: SubjectWebController())
    try redirectMiddle.register(collection: TopicWebController())
    try redirectMiddle.register(collection: MultipleChoiseTaskWebController())
    try redirectMiddle.register(collection: NumberInputTaskWebController())
    try redirectMiddle.register(collection: CreatorWebController())
    try redirectMiddle.register(collection: FlashCardTaskWebController())
    try redirectMiddle.register(collection: SubtopicWebController())
    try redirectMiddle.register(collection: PracticeSessionWebController())
}

private func setupApi(for router: Router) throws {

    let authMiddleware = router.grouped(
        User.tokenAuthMiddleware(), User.authSessionsMiddleware(), User.guardAuthMiddleware()
    )

    try router.register(collection: UserController())
    try authMiddleware.register(collection: SubjectController.shared)
    try authMiddleware.register(collection: TopicController.shared)
    try authMiddleware.register(collection: MultipleChoiseTaskController.shared)
    try authMiddleware.register(collection: PracticeSessionController.shared)
    try authMiddleware.register(collection: NumberInputTaskController())
    try authMiddleware.register(collection: FlashCardTaskController())
    try authMiddleware.register(collection: TaskResultController())
    try authMiddleware.register(collection: SubtopicController())
}
