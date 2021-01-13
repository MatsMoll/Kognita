//
//  TermWebController.swift
//  
//
//  Created by Mats Mollestad on 12/01/2021.
//

import Vapor
import KognitaModels
import KognitaAPI
import KognitaViews

struct TermWebController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        let termInstance = routes.grouped("terms", Term.parameter)
        termInstance.get("resources", use: resourcesForTerm(on:))
    }
    
    func resourcesForTerm(on req: Request) throws -> EventLoopFuture<View> {
        let termID = try req.parameters.get(Term.self)
        return req.repositories { repo in
            repo.resourceRepository.resourcesFor(termIDs: [termID])
        }
        .flatMap { resources in
            ResourceCardList().render(with: .init(resources: resources), for: req)
        }
    }
}
