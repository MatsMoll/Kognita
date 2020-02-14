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
import FluentPostgreSQL
import KognitaAPI
import Authentication

final class UserWebController: RouteCollection {

    func boot(router: Router) {

        let redirectMiddle = router.grouped(RedirectMiddleware<User>(path: "/login"))

        redirectMiddle.get("profile",                   use: profilePage)

        router.get("signup",                            use: signupForm)
        router.get("login",                             use: loginForm)
        router.get("start-reset-password",              use: startResetPasswordForm)
        router.get("reset-password",                    use: resetPasswordForm)
        router.get("users", "verified",                 use: verified(on: ))
        router.get("users", User.parameter, "verify",   use: verify(on: ))

        router.post("login",                            use: cookieLogin)
        router.post("logout",                           use: logout)
        router.post("signup",                           use: create)
        router.post("start-reset-password",             use: startResetPassword)
        router.post("reset-password",                   use: resetPassword)

    }

    func signupForm(_ req: Request) throws -> EventLoopFuture<View> {
        User.Templates.Signup()
            .render(with: .init(), for: req)
    }

    func profilePage(_ req: Request) throws -> EventLoopFuture<View> {
        let user = try req.requireAuthenticated(User.self)

        return try Subject.DatabaseRepository
            .allActive(for: user, on: req)
            .map { subjects in

                try req.renderer()
                    .render(
                        view: User.Templates.Profile.self,
                        with: .init(
                            user: user,
                            subjects: subjects
                        )
                )
        }
    }

    func loginForm(_ req: Request) throws -> EventLoopFuture<Response> {

        if try req.authenticated(User.self) != nil {
            return req.future(req.redirect(to: "/subjects"))
        }

        return try req.renderer()
            .render(LoginPage.self, with: .init())
            .encode(for: req)
    }

    func create(_ req: Request) throws -> EventLoopFuture<Response> {

        return try req.content
            .decode(User.Create.Data.self)
            .flatMap { createUser in

                try User.DefaultAPIController
                    .create(req)
                    .flatMap { newUser in

                        User.authenticate(
                            username: createUser.email,
                            password: createUser.password,
                            using: BCryptDigest(),
                            on: req
                        )
                            .map { user in

                                guard let user = user else {
                                    throw User.DatabaseRepository.Errors.unauthorized
                                }
                                try req.authenticate(user)
                                return req.redirect(to: "/subjects")
                        }
                }
                .catchFlatMap({ (error) in
                    switch error {
                    case is User.DatabaseRepository.Errors:
                        return try req.renderer()
                            .render(
                                User.Templates.Signup.self,
                                with: .init(
                                    errorMessage: error.localizedDescription,
                                    submittedForm: createUser
                                )
                            )
                            .encode(for: req)
                    default:
                        throw error
                    }
                })
            }
    }

    func cookieLogin(_ req: Request) throws -> EventLoopFuture<Response> {
        return try req.content
            .decode(UserLogin.self)
            .flatMap { login in

                return User
                    .authenticate(
                        username: login.email,
                        password: login.password,
                        using: BCryptDigest(),
                        on: req
                )
                    .flatMap { user in

                    guard let user = user else {
                        return try req.renderer()
                            .render(LoginPage.self, with: .init(errorMessage: "Feil brukernavn eller passord"))
                            .encode(for: req)
                    }
                    try req.authenticate(user)
                    return req.future()
                        .transform(to: req.redirect(to: "/subjects"))
                }
        }
    }

    func logout(_ req: Request) throws -> Response {
        try req.unauthenticateSession(User.self)
        return req.redirect(to: "/")
    }


    func startResetPasswordForm(on req: Request) throws -> HTTPResponse {

        return try req.renderer()
            .render(
                User.Templates.ResetPassword.Start.self,
                with: .init()
        )
    }

    func startResetPassword(on req: Request) throws -> EventLoopFuture<HTTPResponse> {

        let successPage = try req.renderer()
            .render(
                User.Templates.ResetPassword.Start.self,
                with: .init(state: .success)
        )
        return try User.DefaultAPIController
            .startResetPassword(on: req)
            .transform(to: successPage)
    }

    func resetPasswordForm(req: Request) throws -> HTTPResponse {

        if let tokenContent = try? req.query
            .decode(User.ResetPassword.Token.Data.self) {

            return try req.renderer()
                .render(
                    User.Templates.ResetPassword.Reset.self,
                    with: .init(token: tokenContent.token)
            )
        } else {

            return try req.renderer()
                .render(
                    User.Templates.ResetPassword.Reset.self,
                    with: .init(
                        token: "",
                        alertMessage: (
                            message: "Ups! Denne forespørselen er enten gått ut på dato, eller eksisterer ikke",
                            colorClass: "danger"
                        ) // FIXME: - Not presenting error message
                    )
            )
        }
    }

    func resetPassword(req: Request) throws -> EventLoopFuture<Response> {
        return try User.DefaultAPIController
            .resetPassword(on: req)
            .transform(to: req.redirect(to: "/login"))
    }

    func verify(on req: Request) throws -> EventLoopFuture<Response> {
        try User.DefaultAPIController
            .verify(on: req)
            .map { _ in
                req.redirect(to: "/users/verified")
        }
    }

    func verified(on req: Request) throws -> HTTPResponse {
        try req.renderer()
            .render(User.Templates.VerifiedConfirmation.self)
    }
}

struct UserLogin: Content {
    let email: String
    let password: String
}
