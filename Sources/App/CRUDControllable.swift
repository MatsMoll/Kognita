//
//  CRUDControllable.swift
//  App
//
//  Created by Mats Mollestad on 09/11/2018.
//

import Vapor

/// A protocol simplefying CRUD controllers
protocol CRUDControllable {

    associatedtype Model: Content

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
