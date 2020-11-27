//
//  HTMLKitErrorMiddleware.swift
//  App
//
//  Created by Mats Mollestad on 27/11/2020.
//

import Vapor
import HTMLKit


/// Captures all errors and transforms them into an internal server error.
public struct HTMLKitErrorMiddleware<F: HTMLPage, S: HTMLPage>: Middleware {
    
    /// A path to ignore
    let ignorePath: String

    /// Create a new ErrorMiddleware for the supplied pages.
    public init(notFoundPage: F.Type, serverErrorTemplate: S.Type, ignorePath: String) {
        self.ignorePath = ignorePath
    }

    /// Create a new ErrorMiddleware
    public init(ignorePath: String) {
        self.ignorePath = ignorePath
    }

    /// See `Middleware.respond`
    public func respond(to req: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        return next.respond(to: req).flatMap { (res: Response) in
            if res.status.code >= HTTPResponseStatus.badRequest.code {
                return self.handleError(for: req, status: res.status)
            } else {
                return res.encodeResponse(for: req)
            }
        }.flatMapError { error in
            do {
                guard req.url.path.hasPrefix(ignorePath) == false else {
                    throw error
                }
                switch error {
                case let abort as AbortError:
                    return self.handleError(for: req, status: abort.status)
                default:
                    return self.handleError(for: req, status: .internalServerError)
                }
            } catch {
                return req.eventLoop.future(error: error)
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
