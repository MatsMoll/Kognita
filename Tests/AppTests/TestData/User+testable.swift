//
//  User+testable.swift
//  AppTests
//
//  Created by Mats Mollestad on 09/11/2018.
//

import Vapor
import FluentPostgreSQL
import Crypto
@testable import KognitaCore
@testable import App


extension User {
    static func create(name: String = "Mats", email: String? = nil, isCreator: Bool = true, on conn: PostgreSQLConnection) throws -> User {
        
        let createEmail = email ?? UUID().uuidString + "@live.com"
        
        let password = try BCrypt.hash("password")
        let user = User(name: name, email: createEmail, passwordHash: password, isCreator: isCreator)
        return try user.save(on: conn).wait()
    }
}
