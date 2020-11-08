//
//  UserWebController.swift
//  App
//
//  Created by Mats Mollestad on 08/10/2018.
//

import Vapor
import Crypto
import KognitaCore
import KognitaViews
import Mailgun
import KognitaAPI
import HTMLKit

final class UserWebController: RouteCollection {

    func boot(routes: RoutesBuilder) throws {

        routes.get("signup", use: signupForm)
        routes.get("login", use: loginForm)
        routes.get("start-reset-password", use: startResetPasswordForm)
        routes.get("reset-password", use: resetPasswordForm)
        routes.get("users", "verified", use: verified(on: ))
        routes.get("users", User.parameter, "verify", use: verify(on: ))

        routes.post("login", use: cookieLogin)
        routes.post("logout", use: logout)
        routes.post("signup", use: create)
        routes.post("start-reset-password", use: startResetPassword)
        routes.post("reset-password", use: resetPassword)

    }

    func signupForm(_ req: Request) throws -> EventLoopFuture<View> {
        User.Templates.Signup()
            .render(with: .init(showCookieMessage: req.cookies.isAccepted == false), for: req)
    }

    func loginForm(_ req: Request) throws -> EventLoopFuture<Response> {

        if req.auth.get(User.self) != nil {
            return req.eventLoop.future(req.redirect(to: "/subjects"))
        }

        return try req.htmlkit
            .render(LoginPage.self, with: .init(showCookieMessage: req.cookies.isAccepted == false))
            .encodeResponse(for: req)
    }

    func create(_ req: Request) throws -> EventLoopFuture<Response> {

        try req.controllers.userController
            .create(on: req)
            .map { user in
                req.auth.login(user)
                return req.redirect(to: "/subjects")
        }
        .flatMapError { error in
            switch error {
            case is User.DatabaseRepository.Errors:
                guard
                    let createUser = try? req.content.decode(User.Create.Data.self),
                    let response = try? req.htmlkit.render(
                        User.Templates.Signup.self,
                        with: .init(
                            showCookieMessage: req.cookies.isAccepted == false,
                            errorMessage: error.localizedDescription,
                            submittedForm: createUser
                        )
                    )
                else { return req.eventLoop.future(error: Abort(.internalServerError)) }
                return response.encodeResponse(for: req)
            default:
                return req.eventLoop.future(error: error)
            }
        }
    }

    func cookieLogin(_ req: Request) throws -> EventLoopFuture<Response> {

        guard let login = try? req.content.decode(UserLogin.self) else { throw Abort(.badRequest) }

        return req.repositories { repositories in
            return repositories.userRepository.verify(email: login.email, with: login.password)
                .failableFlatMap { user in
                    guard let user = user else {
                        return try req.htmlkit
                            .render(LoginPage.self, with: .init(showCookieMessage: req.cookies.isAccepted == false, errorMessage: "Feil brukernavn eller passord"))
                            .encodeResponse(for: req)
                    }
                    req.auth.login(user)
                    return repositories.userRepository.logLogin(for: user, with: req.remoteAddress?.ipAddress)
                        .map { req.redirect(to: "/subjects") }
            }
        }
    }

    func logout(_ req: Request) throws -> Response {
        req.auth.logout(User.self)
        return req.redirect(to: "/")
    }

    func startResetPasswordForm(on req: Request) throws -> Response {

        return try req.htmlkit
            .render(
                User.Templates.ResetPassword.Start.self,
                with: .init(showCookieMessage: req.cookies.isAccepted == false)
        )
    }

    func startResetPassword(on req: Request) throws -> EventLoopFuture<Response> {

        let successPage = try req.htmlkit
            .render(
                User.Templates.ResetPassword.Start.self,
                with: .init(state: .success, showCookieMessage: req.cookies.isAccepted == false)
        )
        return try req.controllers.userController
            .startResetPassword(on: req)
            .transform(to: successPage)
    }

    func resetPasswordForm(req: Request) throws -> Response {

        if let tokenContent = try? req.query
            .decode(User.ResetPassword.Token.Data.self) {

            return try req.htmlkit
                .render(
                    User.Templates.ResetPassword.Reset.self,
                    with: .init(token: tokenContent.token, showCookieMessage: req.cookies.isAccepted == false)
            )
        } else {

            return try req.htmlkit
                .render(
                    User.Templates.ResetPassword.Reset.self,
                    with: .init(
                        token: "",
                        showCookieMessage: req.cookies.isAccepted == false,
                        alertMessage: (
                            message: "Ups! Denne forespørselen er enten gått ut på dato eller eksisterer ikke",
                            colorClass: "danger"
                        ) // FIXME: - Not presenting error message
                    )
            )
        }
    }

    func resetPassword(req: Request) throws -> EventLoopFuture<Response> {
        try req.controllers.userController
            .resetPassword(on: req)
            .transform(to: req.redirect(to: "/login"))
    }

    func verify(on req: Request) throws -> EventLoopFuture<Response> {
        try req.controllers.userController
            .verify(on: req)
            .map { _ in
                req.redirect(to: "/users/verified")
        }
    }

    func verified(on req: Request) throws -> Response {
        try req.htmlkit
            .render(User.Templates.VerifiedConfirmation.self)
    }
}

struct UserLogin: Content {
    let email: String
    let password: String
}
