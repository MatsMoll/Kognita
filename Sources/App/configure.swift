import Vapor
import HTMLKitVaporProvider
import KognitaCore
import KognitaViews
import KognitaAPI
import Mailgun

/// A provider for the web routes to use
struct WebRouteProvider: LifecycleHandler {
    func willBoot(_ application: Application) throws {
        try routes(application)
    }
}

/// Called before your application initializes.
public func configure(_ app: Application) throws {

    app.lifecycle.use(KognitaAPIProvider(env: app.environment))

//    // Serves files from `Public/` directory
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    guard let rootUrl = Environment.get("ROOT_URL") else {
        fatalError("Need to set a ROOT_URL")
    }
    app.lifecycle.use(HTMLKitLifecycle(rootUrl: rootUrl))
    // Adds htmlkit to the app lifecycle after setting up the templates
    _ = app.htmlkit

    // Catches errors and converts to HTTP responses for developers
    app.middleware.use(ErrorMiddleware.default(environment: app.environment))
    // After ErrorMiddleware in order to not konvert error into html
    app.middleware.use(HTMLKitErrorMiddleware<Pages.NotFoundError, Pages.ServerError>(ignorePath: "/api"))

    if app.environment != .production {
        app.logger.logLevel = .debug
    }
    // Needs to run after the API config as there are setup that needs to happend
    // Before the web routes are added. Like session middleware config
    app.lifecycle.use(WebRouteProvider())
}

private func registerRouter(in app: Application) throws {
    try routes(app)
}

struct ResetPasswordMailRenderer: ResetPasswordMailRenderable {
    let renderer: HTMLRenderable

    public func render(with token: User.ResetPassword.Token, for user: User) throws -> String {
        try renderer.render(
            raw: User.Templates.ResetPassword.Mail.self,
            with: .init(
                user: user,
                token: token
            )
        )
    }
}

struct VerifyEmailRenderer: VerifyEmailRenderable {
    let renderer: HTMLRenderable

    func render(with content: User.VerifyEmail.EmailContent, on request: Request) throws -> EventLoopFuture<String> {
        let html = try renderer.render(
            raw: User.Templates.VerifyMail.self,
            with: User.Templates.VerifyMail.Context(
                token: content
            )
        )
        return request.eventLoop.future(html)
    }
}

extension HTTPStatus {
    internal init(_ error: Error) {
        if let abort = error as? AbortError {
            self = abort.status
        } else {
            self = .internalServerError
        }
    }
}
