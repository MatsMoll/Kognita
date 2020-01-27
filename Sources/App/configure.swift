import Authentication
import FluentPostgreSQL
import Vapor
import HTMLKitVaporProvider
import KognitaCore
import KognitaViews
import KognitaAPI
import Mailgun

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {

    // Register providers first
    try services.register(KognitaAPIProvider(env: env))

    // Sets the templating framework and Web Sessions
    config.prefer(MemoryKeyedCache.self, for: KeyedCache.self)

    try registerRouter(in: &services)

    var middlewares = MiddlewareConfig()

    // Enables sessions.
    middlewares.use(SessionsMiddleware.self)

    // Serves files from `Public/` directory
    middlewares.use(FileMiddleware.self)

    if env != .production {
        // Catches errors and converts to HTTP responses for developers
        middlewares.use(ErrorMiddleware.self)
    } else {
        // Catches errors and converts to HTTP responses for users
        middlewares.use(HTMLKitErrorMiddleware<Pages.NotFoundError, Pages.ServerError>.self)
    }
    
    services.register(middlewares)
    services.register(APIControllerCollection.defaultControllers)
    services.register { _ in
        HTMLKitErrorMiddleware(
            notFoundPage: Pages.NotFoundError.self,
            serverErrorTemplate: Pages.ServerError.self
        )
    }

    let renderer = try KognitaViews.renderer(env: env)

    let path = DirectoryConfig.detect().workDir + "Resources/Localization"
    try renderer.registerLocalization(atPath: path, defaultLocale: "nb")
    renderer.timeZone = TimeZone(identifier: "CET") ?? .current

    services.register(renderer)
    services.register(renderer, as: ResetPasswordMailRenderable.self)
    services.register(renderer, as: VerifyEmailRenderable.self)
}

private func registerRouter(in services: inout Services) throws {
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)
}

extension HTMLRenderer: ResetPasswordMailRenderable {
    public func render(with token: User.ResetPassword.Token.Create.Response, for user: User) throws -> String {
        try render(
                raw: User.Templates.ResetPassword.Mail.self,
                with: .init(
                    user: user,
                    changeUrl: "https://uni.kognita.no/reset-password?token=\(token.token)"
                )
        )
    }
}

extension HTMLRenderer: VerifyEmailRenderable {
    public func render(with content: User.VerifyEmail.EmailContent, on container: Container) throws -> EventLoopFuture<String> {
        let html = try render(
            raw: User.Templates.VerifyMail.self,
            with: User.Templates.VerifyMail.Context(
                token: content
            )
        )
        return container.future(html)
    }
}
