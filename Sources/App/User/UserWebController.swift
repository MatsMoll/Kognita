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

final class UserWebController: RouteCollection {

    let controller = UserController()

    func boot(router: Router) {

        router.get("signup", use: signupForm)
        router.get("login", use: loginForm)
        router.post("login", use: login)
        router.post("logout", use: logout)
        router.post("signup", use: create)
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
}

struct UserLogin: Content {
    let email: String
    let password: String
}
