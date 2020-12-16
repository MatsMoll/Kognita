//
//  HTMLKitErrorMiddleware.swift
//  App
//
//  Created by Mats Mollestad on 27/11/2020.
//

import Vapor
import HTMLKit
//import Combine
//
///// Can represent a path e.g a `String` or a `Identifiable` object
//protocol EndpointPathItem {
//    var pathDescription: String { get }
//    var pathIdentifier: String { get }
//}
//
//extension String: EndpointPathItem {
//    var pathDescription: String { self }
//    var pathIdentifier: String { self }
//}
//
//struct SimpleGet: Endpoint {
//    let method: Method = .get
//    var pathComponents: [String]
//}
//
//struct SimplePost: Endpoint {
//    let method: Method = .post
//    var pathComponents: [String]
//
//    func with<C: Codable>(content: C.Type) -> PostWithContent<C> { .init(pathComponents: pathComponents) }
//}
//
//struct PostWithContent<Content: Codable>: Endpoint {
//    let method: Method = .get
//    var pathComponents: [String]
//}
//
//enum Method {
//    case post
//    case get
//    case put
//    case delete
//}
//
//protocol Endpoint {
//    var method: Method { get }
//    var pathComponents: [String] { get }
//}
//
//struct ParameterPost<T: Identifiable>: Endpoint {
//    let method: Method = .post
//    var pathComponents: [String]
//
//    func request<C: Codable>(body: C.Type) -> ParameterContentPost<T, C> { .init(pathComponents: pathComponents) }
//}
//
//struct ParameterContentPost<T: Identifiable, Content: Codable>: Endpoint {
//    let method: Method = .post
//    var pathComponents: [String]
//
//    func respone<R: Codable>(body: R.Type) -> ParameterContentPostWithResponse<T, Content, R> {
//        .init(pathComponents: pathComponents)
//    }
//}
//
//struct ParameterContentPostWithResponse<T: Identifiable, Content: Codable, Response: Codable>: Endpoint {
//    let method: Method = .post
//    var pathComponents: [String]
//}
//
//enum EndpointBuilder {
//    static func post<P: Identifiable>(to paths: String, _ parameter: P.Type) -> ParameterPost<P> {
//        ParameterPost(pathComponents: [paths, ":\(String(reflecting: P.self))"])
//    }
//}
//
//// Some extensions only available in the Vapor code
//extension Endpoint {
//    var vaporPathComponents: [PathComponent] {
//        pathComponents.map { path in
//            if path.hasPrefix(":") {
//                return .parameter(String(path.dropFirst()))
//            } else {
//                return .constant(path)
//            }
//        }
//    }
//}
//
//extension ParameterContentPostWithResponse {
//    func resolve(req: Request, implementation: (T.ID, Content, Request) -> EventLoopFuture<Response>) -> EventLoopFuture<Response> {
//        let id = req.parameters.get(String(reflecting: T.self)) as! T.ID // Needs some String literal init for the ID
//        let content = try! req.content.decode(Content.self)
//        return implementation(id, content, req)
//    }
//}
//
//extension ParameterContentPostWithResponse where Response: Vapor.Response {
//
//    func register(in route: RoutesBuilder, _ implementation: (T.ID, Content, Request) -> EventLoopFuture<Response>) {
//        route.on(.POST, vaporPathComponents) { (req) -> EventLoopFuture<Response> in
//            resolve(req: req, implementation: implementation)
//        }
//    }
//}
//
//// Some extensions only available in the iOS code
//extension ParameterContentPostWithResponse {
//    func request(with id: T.ID, content: Content, baseURL: URL) -> AnyPublisher<Response, Error> {
//        let url = baseURL.appendingPathComponent(pathComponents.first! + "/\(id)")
//        var urlRequest = URLRequest(url: url)
//        urlRequest.httpMethod = "POST"
//        urlRequest.httpBody = try! JSONEncoder().encode(content)
//        return URLSession.shared.dataTaskPublisher(for: urlRequest)
//            .map(\.data)
//            .decode(type: Response.self, decoder: JSONDecoder())
//            .eraseToAnyPublisher()
//    }
//}
//
//extension ParameterPost {
//    func resolve(req: Request, function: (T.ID, Request) -> EventLoopFuture<Void>) -> EventLoopFuture<Void> {
//        let id = req.parameters.get(String(reflecting: T.self))
//        return function(id as! T.ID, req)
//    }
//}
//
//extension ParameterContentPost {
//    func resolve(req: Request, implementation: (T.ID, Content, Request) -> EventLoopFuture<Void>) -> EventLoopFuture<Void> {
//        let id = req.parameters.get(String(reflecting: T.self)) as! T.ID // Needs some string literal init for the ID
//        let content = try! req.content.decode(Content.self)
//        return implementation(id, content, req)
//    }
//
//    func register(in route: RoutesBuilder, _ implementation: (T.ID, Content, Request) -> EventLoopFuture<Void>) {
//        route.on(.POST, vaporPathComponents) { (req) -> EventLoopFuture<HTTPStatus> in
//            self.resolve(req: req, implementation: implementation)
//                .transform(to: .ok)
//        }
//    }
//}
//
//extension PostWithContent {
//    func resolve(req: Request, function: (Content, Request) -> EventLoopFuture<Void>) -> EventLoopFuture<Void> {
//        let content = try! req.content.decode(Content.self)
//        return function(content, req)
//    }
//}
//
//
//extension ParameterPost {
//    func request(with id: T.ID, baseURL: URL) -> URLSession.DataTaskPublisher {
//        let url = baseURL.appendingPathComponent(pathComponents.first! + "/\(id)")
//        return URLSession.shared.dataTaskPublisher(for: url)
//    }
//}
//
//extension ParameterContentPost {
//    func request(with id: T.ID, content: Content, baseURL: URL) -> URLSession.DataTaskPublisher {
//        let url = baseURL.appendingPathComponent(pathComponents.first! + "/\(id)")
//        var urlRequest = URLRequest(url: url)
//        urlRequest.httpBody = try! JSONEncoder().encode(content)
//        return URLSession.shared.dataTaskPublisher(for: urlRequest)
//    }
//}
//
//extension PostWithContent {
//    func makeRequest(with content: Content, baseURL: URL) -> URLSession.DataTaskPublisher {
//        let url = baseURL.appendingPathComponent(pathComponents.first!)
//        var urlRequest = URLRequest(url: url)
//        urlRequest.httpMethod = "POST"
//        urlRequest.httpBody = try! JSONEncoder().encode(content)
//        return URLSession.shared.dataTaskPublisher(for: urlRequest)
//    }
//}
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
