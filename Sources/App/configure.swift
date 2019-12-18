import Authentication
import FluentPostgreSQL
import Vapor
import HTMLKit
import HTMLKitVapor
import KognitaCore
import KognitaViews
import KognitaAPI
import Mailgun

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {

    // Register providers first
    try services.register(FluentPostgreSQLProvider())
    try services.register(AuthenticationProvider())

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
    services.register { _ in
        HTMLKitErrorMiddleware(
            notFoundPage: Pages.NotFoundError.self,
            serverErrorTemplate: Pages.ServerError.self
        )
    }

    let templates = try setupTemplates()
    services.register(templates)
    services.register(templates, as: ResetPasswordMailRenderable.self)

    KognitaAPI.setupApi(with: env, in: &services)
}

private func registerRouter(in services: inout Services) throws {
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)
}

func setupTemplates() throws -> HTMLRenderer {

    let renderer = HTMLRenderer()

    let path = DirectoryConfig.detect().workDir + "Resources/Localization"
    try renderer.registerLocalization(atPath: path, defaultLocale: "nb")

    // Starter
    try renderer.add(view: Pages.Landing())

    // Error Pages
    try renderer.add(view: Pages.ServerError())
    try renderer.add(view: Pages.NotFoundError())

    // Auth
    try renderer.add(view: LoginPage())
    try renderer.add(view: User.Templates.Signup())
    try renderer.add(view: User.Templates.ResetPassword.Start())
    try renderer.add(view: User.Templates.ResetPassword.Mail())
    try renderer.add(view: User.Templates.ResetPassword.Reset())

    // Main User pages
    try renderer.add(view: Subject.Templates.ListOverview())
    try renderer.add(view: Subject.Templates.Details())
    try renderer.add(view: Subject.Templates.SelectRedirect())

//    // Task Overview
//    try renderer.add(template: TaskOverviewListTemplate())

//    // Task Template
    try renderer.add(view: FlashCardTask.Templates.Execute())
    try renderer.add(view: MultipleChoiseTask.Templates.Execute())
    try renderer.add(view: NumberInputTask.Templates.Execute())
    try renderer.add(view: TaskSolutionsTemplate())
//
//    // Create Content
    try renderer.add(view: Subject.Templates.Create())
    try renderer.add(view: Topic.Templates.Create())
    try renderer.add(view: Subtopic.Templates.Create())
//
//    // Create Task Templates
    try renderer.add(view: FlashCardTask.Templates.Create())
    try renderer.add(view: MultipleChoiseTask.Templates.Create())
    try renderer.add(view: NumberInputTask.Templates.Create())
//
//    // Practice Session
    try renderer.add(view: PracticeSession.Templates.History())
    try renderer.add(view: PracticeSession.Templates.Result())

//    // Creator pages
    try renderer.add(view: CreatorTemplates.Dashboard())
    try renderer.add(view: CreatorTemplates.TopicDetails())
    try renderer.add(view: Subject.Templates.ContentOverview())
//    try renderer.add(template: CreatorInformationPage())
    return renderer
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
