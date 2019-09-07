//
//  Router+CRUDControllable.swift
//  App
//
//  Created by Mats Mollestad on 09/11/2018.
//

import Vapor

extension Router {

    /// Registers a CRUD controller on a route
    ///
    /// - Parameter: controller
    ///     The controller to add
    func register<T: CRUDControllable>(_ controller: T) {
        get    ("/", use: controller.getInstanceCollection)
        post   ("/", use: controller.create)
        get    ("/", controller.parameter, use: controller.getInstance)
        delete ("/", controller.parameter, use: controller.delete)
        put    ("/", controller.parameter, use: controller.edit)
    }

    /// Registers a CRUD controller on a route
    ///
    /// - Parameters:
    ///     - path:
    ///         The path to register the controller at
    ///     - controller:
    ///         The controller to add
    func register<T: CRUDControllable>(controller: T, at path: PathComponentsRepresentable...) {
        grouped(path).register(controller)
    }
    
    func register<T: KognitaCRUDControllable>(_ controller: T) {
        post    ("/",                       use: controller.create)
        get     ("/",                       use: controller.getAll)
        get     ("/", controller.parameter, use: controller.get)
        delete  ("/", controller.parameter, use: controller.delete)
        put     ("/", controller.parameter, use: controller.edit)
    }
    
    func register<T: KognitaCRUDControllable>(controller: T, at path: PathComponentsRepresentable...) {
        grouped(path).register(controller)
    }
}
