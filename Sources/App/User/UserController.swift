import Crypto
import Vapor
import FluentPostgreSQL
import KognitaCore

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

        return try UserRepository.shared
            .login(with: user, conn: req)
    }

    /// Creates a new user.
    func create(_ req: Request) throws -> Future<UserResponse> {
        // decode request content
        return try req.content
            .decode(CreateUserRequest.self)
            .flatMap { content in
                try UserRepository.shared
                    .create(with: content, conn: req)
        }
    }

    func getAllUsers(on req: Request) throws -> Future<[UserResponse]> {
        let user = try req.requireAuthenticated(User.self)
        guard user.isCreator else {
            throw Abort(.forbidden)
        }
        return UserRepository.shared
            .getAll(on: req)
    }
}

// MARK: Content

///// Data required to create a user.
//struct CreateUserRequest: Content {
//    /// User's full name.
//    var name: String
//
//    /// User's email address.
//    var email: String
//
//    /// User's desired password.
//    var password: String
//
//    /// User's password repeated to ensure they typed it correctly.
//    var verifyPassword: String
//
//    /// If the terms is accepted
//    var acceptedTermsInput: String
//
//    var acceptedTerms: Bool { return acceptedTermsInput == "on" }
//}
//
///// Public representation of user data.
//struct UserResponse: Content {
//    /// User's unique identifier.
//    /// Not optional since we only return users that exist in the DB.
//    var id: Int
//
//    /// User's full name.
//    var name: String
//
//    /// User's email address.
//    var email: String
//}
