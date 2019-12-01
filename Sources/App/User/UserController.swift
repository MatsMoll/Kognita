import Crypto
import Vapor
import FluentPostgreSQL
import KognitaCore
import Mailgun
import KognitaViews

/// Creates new users and logs them in.
final class UserController: RouteCollection {

    static let shared = UserController()

    func boot(router: Router) {
        // public routes
        let userController = UserController()
        router.post("users", use: userController.create)

        // basic / password auth protected routes
        let basic = router.grouped(User.basicAuthMiddleware(using: BCryptDigest()))
        basic.post("users/login", use: userController.login)

        let auth = basic.grouped(User.authSessionsMiddleware())
        auth.get("users/overview", use: userController.getAllUsers)
    }

    /// Logs a user in, returning a token for accessing protected endpoints.
    func login(_ req: Request) throws -> Future<UserToken> {
        // get user auth'd by basic auth middleware
        let user = try req.requireAuthenticated(User.self)

        return try User.Repository
            .login(with: user, conn: req)
    }

    /// Creates a new user.
    func create(_ req: Request) throws -> Future<User.Response> {
        // decode request content
        return try req.content
            .decode(User.Create.Data.self)
            .flatMap { content in
                try User.Repository
                    .create(from: content, by: nil, on: req)
        }
    }

    func getAllUsers(on req: Request) throws -> Future<[User.Response]> {
        let user = try req.requireAuthenticated(User.self)
        guard user.isCreator else {
            throw Abort(.forbidden)
        }
        return User.Repository
            .getAll(on: req)
    }
}
