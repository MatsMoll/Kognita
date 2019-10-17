//
//  CRUDControllable.swift
//  App
//
//  Created by Mats Mollestad on 09/11/2018.
//

import Vapor
import KognitaCore

/// A protocol simplefying CRUD controllers
protocol CRUDControllable {

    associatedtype Model : Content

    /// Returns a collection of a model type
    ///
    /// - Parameter req:
    ///     The request sendt
    ///
    /// - Returns:
    ///     A collection of a model type
    func getInstanceCollection(_ req: Request) throws -> Future<[Model]>

    /// Returns a single model object
    ///
    /// - Parameter req:
    ///     The request sendt
    ///
    /// - Returns:
    ///     A single model object
    func getInstance(_ req: Request) throws -> Future<Model>

    /// Creates a model object
    ///
    /// - Parameter req:
    ///     The request sendt
    ///
    /// - Returns:
    ///     The new model object
    func create(_ req: Request) throws -> Future<Model>

    /// Deletes a model object
    ///
    /// - Parameter req:
    ///     The request sendt
    ///
    /// - Returns:
    ///     A status enum indication if it was sucessfull
    func delete(_ req: Request) throws -> Future<HTTPStatus>

    /// Edits a model object
    ///
    /// - Parameter req:
    ///     The request sendt
    ///
    /// - Returns:
    ///     The edited model object
    func edit(_ req: Request) throws -> Future<Model>

    /// The models parameter representation
    var parameter: PathComponentsRepresentable { get }
}

/// An extension that makes it easier to use the protocol
extension CRUDControllable where Model: Parameter {
    var parameter: PathComponentsRepresentable { return Model.parameter }
}


/// A protocol simplefying CRUD controllers
protocol KognitaCRUDControllable {

    associatedtype Model : KognitaCRUDModel
    associatedtype ResponseContent : Content
    
    static var shared: Self { get }

    /// Creates a model object
    ///
    /// - Parameter req:
    ///     The request sendt
    ///
    /// - Returns:
    ///     The new model object
    func create(_ req: Request) throws -> Future<ResponseContent>

    /// Deletes a model object
    ///
    /// - Parameter req:
    ///     The request sendt
    ///
    /// - Returns:
    ///     A status enum indication if it was sucessfull
    func delete(_ req: Request) throws -> Future<HTTPStatus>

    /// Edits a model object
    ///
    /// - Parameter req:
    ///     The request sendt
    ///
    /// - Returns:
    ///     The edited model object
    func edit(_ req: Request) throws -> Future<ResponseContent>
    
    /// Returns the Model
    ///
    /// - Parameter req: The `Request` sendt to the server
    ///
    /// - Returns: A `Future<ResponseContent>`
    func get(_ req: Request) throws -> Future<ResponseContent>
    
    /// Returns all of the `Model`s
    ///
    /// - Parameter req: The `Request` sendt to the server
    ///
    /// - Returns: A `Future<ResponseContent>`
    func getAll(_ req: Request) throws -> Future<[ResponseContent]>
    
    
    /// Maps a `Model` to a `ResponseContent`
    ///
    /// - Parameters:
    ///     - model: The `Model` to map
    ///     - conn: A database connection
    ///
    /// - Returns: A `Future<ResponseContent>`
    func map(model: Model, on conn: DatabaseConnectable) throws -> Future<ResponseContent>
    
    /// Maps a `Model.Create.Response` to a `ResponseContent`
    ///
    /// - Parameters:
    ///     - model: The `Model.Create.Response` to map
    ///     - conn: A database connection
    ///
    /// - Returns: A `Future<ResponseContent>`
    func mapCreate(response: Model.Create.Response, on conn: DatabaseConnectable) throws -> Future<ResponseContent>
    
    /// Maps a `Model.Edit.Response` to a `ResponseContent`
    ///
    /// - Parameters:
    ///     - model: The `Model.Edit.Response` to map
    ///     - conn: A database connection
    ///
    /// - Returns: A `Future<ResponseContent>`
    func mapEdit(response: Model.Edit.Response, on conn: DatabaseConnectable) throws -> Future<ResponseContent>

    /// The models parameter representation
    var parameter: PathComponentsRepresentable { get }
}

extension KognitaCRUDControllable where Model == ResponseContent {
    func map(model: Model, on conn: DatabaseConnectable) throws -> Future<ResponseContent> {
        return conn.future(model)
    }
}

extension KognitaCRUDControllable where Model.Create.Response == ResponseContent, Model == Model.Create.Response {
    func mapCreate(response: Model.Create.Response, on conn: DatabaseConnectable) throws -> Future<ResponseContent> {
        return conn.future(response)
    }
}

extension KognitaCRUDControllable where Model == Model.Create.Response {
    func mapCreate(response: Model.Create.Response, on conn: DatabaseConnectable) throws -> Future<ResponseContent> {
        return try map(model: response, on: conn)
    }
}

extension KognitaCRUDControllable where Model.Create.Response == ResponseContent {
    func mapCreate(response: Model.Create.Response, on conn: DatabaseConnectable) throws -> Future<ResponseContent> {
        return conn.future(response)
    }
}

extension KognitaCRUDControllable where Model.Create.Response == Model.Edit.Response {
    func mapEdit(response: Model.Edit.Response, on conn: DatabaseConnectable) throws -> Future<ResponseContent> {
        return try self.mapCreate(response: response, on: conn)
    }
}

extension KognitaCRUDControllable where Model.Create.Data : Decodable {
    
    func create(_ req: Request) throws -> Future<ResponseContent> {
        
        let user = try req.authenticated(User.self)
        
        return try req.content
            .decode(Model.Create.Data.self)
            .flatMap { content in
                
                try Model.Repository
                    .create(from: content, by: user, on: req)
                    .flatMap { try Self.shared.mapCreate(response: $0, on: req) }
        }
    }
}

/// An extension that makes it easier to use the protocol
extension KognitaCRUDControllable where Model: Parameter, Model.ResolvedParameter == Future<Model> {
    
    var parameter: PathComponentsRepresentable { return Model.parameter }
    
    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        
        let user = try req.requireAuthenticated(User.self)

        return try req.parameters
            .next(Model.self)
            .flatMap { model in

                try Model.Repository
                    .delete(model, by: user, on: req)
                    .transform(to: .ok)
        }
    }
    
    func get(_ req: Request) throws -> Future<ResponseContent> {

        return try req.parameters
            .next(Model.self)
            .flatMap { try Self.shared.map(model: $0, on: req) }
    }
}

/// An extension that makes it easier to use the protocol
extension KognitaCRUDControllable where Model: Parameter, Model.ResolvedParameter == Future<Model>, Model.Edit.Data : Decodable {
    
    func edit(_ req: Request) throws -> Future<ResponseContent> {
        
        let user = try req.requireAuthenticated(User.self)

        return try req.content
            .decode(Model.Edit.Data.self)
            .flatMap { content in
                
                try req.parameters
                    .next(Model.self)
                    .flatMap { model in
                        
                        try Model.Repository
                            .edit(model, to: content, by: user, on: req)
                            .flatMap { try Self.shared.mapEdit(response: $0, on: req) }
                }
        }
    }
}

protocol KognitaModelRenderable {
    associatedtype Pages
}

protocol KognitaWebController {
    
    associatedtype Model : KognitaPersistenceModel
    
    func create(on req: Request) throws -> Future<HTTPResponse>
}
