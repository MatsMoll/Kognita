import Vapor
import HTMLKitVaporProvider
import KognitaCore
import KognitaViews
import KognitaAPI
import Mailgun

/// Called before your application initializes.
public func configure(_ app: Application) throws {

    app.lifecycle.use(KognitaAPIProvider(env: app.environment))

//    // Serves files from `Public/` directory
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    guard let rootUrl = Environment.get("ROOT_URL") else {
        fatalError("Need to set a ROOT_URL")
    }

    if app.environment != .production {
        // Catches errors and converts to HTTP responses for developers
        app.middleware.use(ErrorMiddleware.default(environment: app.environment))
        app.logger.logLevel = .debug
    } else {
        // Catches errors and converts to HTTP responses for users
        app.middleware.use(HTMLKitErrorMiddleware<Pages.NotFoundError, Pages.ServerError>())
    }
    app.htmlkit.localizationPath = app.directory.workingDirectory + "Resources/Localization"
    app.htmlkit.defaultLocale = "nb"

    try KognitaViews.renderer(rootURL: rootUrl, renderer: app.htmlkit.renderer)

//    try renderer.registerLocalization(atPath: path, defaultLocale: "nb")
//    renderer.timeZone = TimeZone(identifier: "CET") ?? .current

    app.verifyEmailRenderer.use { VerifyEmailRenderer.init(renderer: $0.htmlkit) }
    app.resetPasswordRenderer.use { ResetPasswordMailRenderer.init(renderer: $0.htmlkit) }

    try routes(app)
}

private func registerRouter(in app: Application) throws {
    try routes(app)
}

struct ResetPasswordMailRenderer: ResetPasswordMailRenderable {
    let renderer: HTMLRenderer

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
    let renderer: HTMLRenderer

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

/// Captures all errors and transforms them into an internal server error.
public final class HTMLKitErrorMiddleware<F: HTMLPage, S: HTMLPage>: Middleware {

    /// Create a new ErrorMiddleware for the supplied pages.
    public init(notFoundPage: F.Type, serverErrorTemplate: S.Type) {}

    /// Create a new ErrorMiddleware
    public init() {}

    /// See `Middleware.respond`
    public func respond(to req: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        return next.respond(to: req).flatMap { (res: Response) in
            if res.status.code >= HTTPResponseStatus.badRequest.code {
                return self.handleError(for: req, status: res.status)
            } else {
                return res.encodeResponse(for: req)
            }
        }.flatMapError { error in
            switch error {
            case let abort as AbortError:
                return self.handleError(for: req, status: abort.status)
            default:
                return self.handleError(for: req, status: .internalServerError)
            }
        }
    }

    private func handleError(for req: Request, status: HTTPStatus) -> EventLoopFuture<Response> {

        if status == .notFound {
            do {
                return try req.htmlkit.render(F.self).encodeResponse(for: req).map { res in
                        res.status = status
                        return res
                    }.flatMapError { _ in
                        return self.renderServerErrorPage(for: status, request: req)
                }
            } catch {
                req.logger.error("Failed to render custom error page - \(error)")
                return renderServerErrorPage(for: status, request: req)
            }
        }

        return renderServerErrorPage(for: status, request: req)
    }

    private func renderServerErrorPage(for status: HTTPStatus, request: Request) -> EventLoopFuture<Response> {

        request.logger.error("Internal server error. Status: \(status.code) - path: \(request.url)")

        do {
            return try request.htmlkit.render(S.self).encodeResponse(for: request).map { res in
                res.status = status
                return res
            }.flatMapError { error -> EventLoopFuture<Response> in
                return self.presentDefaultError(status: status, request: request, error: error)
            }
        } catch let error {
            request.logger.error("Failed to render custom error page - \(error)")
            return presentDefaultError(status: status, request: request, error: error)
        }
    }

    private func presentDefaultError(status: HTTPStatus, request: Request, error: Error)  -> EventLoopFuture<Response> {
        let body = "<h1>Internal Error</h1><p>There was an internal error. Please try again later.</p>"
        request.logger.error("Failed to render custom error page - \(error)")
        return body.encodeResponse(for: request)
            .map { res in
                res.status = status
                res.headers.replaceOrAdd(name: .contentType, value: "text/html; charset=utf-8")
                return res
        }
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
