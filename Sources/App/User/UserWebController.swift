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

final class UserWebController: RouteCollection {

    let controller = UserController()

    func boot(router: Router) {

        router.get("signup",                use: signupForm)
        router.get("login",                 use: loginForm)
        router.get("start-reset-password",  use: startResetPasswordForm)
        router.get("reset-password",        use: resetPasswordForm)

        router.post("login",                use: login)
        router.post("logout",               use: logout)
        router.post("signup",               use: create)
        router.post("start-reset-password", use: startResetPassword)
        router.post("reset-password",       use: resetPassword)
    }

    func signupForm(_ req: Request) throws -> HTTPResponse {
        return try req.renderer()
            .render(SignupPage.self, with: .init())
    }

    func loginForm(_ req: Request) throws -> Future<Response> {

        if try req.authenticated(User.self) != nil {
            return req.future(req.redirect(to: "/subjects"))
        }

        return try req.renderer()
            .render(LoginPage.self, with: .init())
            .encode(for: req)
    }

    func create(_ req: Request) throws -> EventLoopFuture<Response> {
        return try req.content.decode(User.Create.Data.self).flatMap { createUser in
            try UserController.shared.create(req).flatMap { newUser in
                User.authenticate(
                    username: createUser.email,
                    password: createUser.password,
                    using: BCryptDigest(),
                    on: req).map { user in
                        guard let user = user else {
                            throw User.Repository.Errors.unauthorized
                        }
                        try req.authenticate(user)
                        return req.redirect(to: "/subjects")
                }
            }
            }.catchFlatMap({ (error) in
                print("Error: ", error)
                switch error {
                case is User.Repository.Errors:
                    return try req.renderer()
                        .render(SignupPage.self, with: .init(errorMessage: error.localizedDescription))
                        .encode(for: req)
                default:
                    throw error
                }
            })
    }

    func login(_ req: Request) throws -> EventLoopFuture<Response> {
        return try req.content
            .decode(UserLogin.self)
            .flatMap { login in

                return User
                    .authenticate(username: login.email,
                                  password: login.password,
                                  using: BCryptDigest(),
                                  on: req)
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
                User.ResetPassword.Templates.Start.self,
                with: .init()
        )
    }

    func startResetPassword(on req: Request) throws -> Future<HTTPResponse> {

        let successPage = try req.renderer()
            .render(
                User.ResetPassword.Templates.Start.self,
                with: .init(
                    alertMessage: (
                        message: "Du skal snart få en email med en link for å gjenopprette passordet ditt",
                        colorClass: "success"
                    )
                )
        )

        return try req.content.decode(User.ResetPassword.Email.self)
            .flatMap { email in

                User.repository
                    .first(where: \User.email == email.email, on: req)
                    .flatMap { user in

                        guard let user = user else {
                            return req.future(successPage)
                        }
                        return try User.ResetPassword.Token.repository
                            .create(by: user, on: req)
                            .flatMap { token in

                                let mailContext = User.ResetPassword.Templates.Mail.Context(
                                    user: user,
                                    changeUrl: "uni.kognita.no/reset-password?token=\(token.token)"
                                )
                                let mailHtml = try req.renderer()
                                    .renderRaw(User.ResetPassword.Templates.Mail.self, with: mailContext)
                                let mail = Mailgun.Message(
                                    from:       "kontakt@kognita.no",
                                    to:         email.email,
                                    subject:    "Kognita - Gjenopprett Passord",
                                    text:       "",
                                    html:       mailHtml
                                )
                                let mailgun = try req.make(Mailgun.self)
                                return try mailgun.send(mail, on: req)
                                    .transform(to: successPage)
//                                return req.future(successPage)
                        }
                }
        }
    }

    func resetPasswordForm(req: Request) throws -> HTTPResponse {

        if let tokenContent = try? req.query
            .decode(User.ResetPassword.Token.Data.self) {

            return try req.renderer()
                .render(
                    User.ResetPassword.Templates.Reset.self,
                    with: .init(token: tokenContent.token)
            )
        } else {

            return try req.renderer()
                .render(
                    User.ResetPassword.Templates.Reset.self,
                    with: .init(
                        token: "",
                        alertMessage: (
                            message: "Ups! Denne forespørselen er enten gått ut på dato, eller eksisterer ikke",
                            colorClass: "danger"
                        )
                    )
            )
        }
    }

    func resetPassword(req: Request) throws -> Future<Response> {

        return try req.content
            .decode(User.ResetPassword.Token.Data.self)
            .flatMap { token in

                try req.content
                    .decode(User.ResetPassword.Data.self)
                    .flatMap { data in

                        try User.ResetPassword.Token.repository
                            .reset(to: data, with: token.token, on: req)
                            .transform(to: req.redirect(to: "/login"))
                }
        }
    }
}

struct UserLogin: Content {
    let email: String
    let password: String
}

extension User.ResetPassword {
    public struct Email : Content {
        let email: String
    }
}
