//
//  FlashCardTaskController.swift
//  App
//
//  Created by Mats Mollestad on 31/03/2019.
//

import Vapor
import KognitaCore

class FlashCardTaskController: RouteCollection, CRUDControllable {

    var parameter: PathComponentsRepresentable { return FlashCardTask.parameter }

    func boot(router: Router) throws {
        router.register(controller: self, at: "tasks/flash-card")
    }

    func create(_ req: Request) throws -> Future<Task> {

        let user = try req.requireAuthenticated(User.self)

        return try req.content
            .decode(FlashCardTaskCreateContent.self)
            .flatMap { content in
                try FlashCardRepository.shared
                    .create(with: content, user: user, conn: req)
        }
    }

    func edit(_ req: Request) throws -> EventLoopFuture<Task> {

        let user = try req.requireAuthenticated(User.self)

        return try req.content
            .decode(FlashCardTaskCreateContent.self)
            .flatMap { content in

                try req.parameters
                    .next(FlashCardTask.self)
                    .flatMap { flashCard in

                        try FlashCardRepository.shared
                            .edit(task: flashCard, with: content, user: user, conn: req)
            }
        }
    }

    func delete(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {

        let user = try req.requireAuthenticated(User.self)

        return try req.parameters
            .next(FlashCardTask.self)
            .flatMap { flashCard in

                try FlashCardRepository.shared
                    .delete(task: flashCard, user: user, conn: req)
                    .transform(to: .ok)
        }
    }

    func getInstance(_ req: Request) throws -> EventLoopFuture<Task> {
        return try req.parameters.next(FlashCardTask.self).flatMap { flashCard in
            try FlashCardRepository.shared
                .get(task: flashCard, conn: req)
        }
    }

    func getInstanceCollection(_ req: Request) throws -> EventLoopFuture<[Task]> {
        return FlashCardTask.query(on: req)
            .join(\FlashCardTask.id, to: \Task.id)
            .decode(Task.self)
            .all()
    }
}


//struct FlashCardTaskCreateContent: TaskCreationContentable, Content {
//
//    let topicId: Topic.ID
//
//    let difficulty: Double
//
//    let estimatedTime: TimeInterval
//
//    let description: String?
//
//    let question: String
//
//    let solution: String?
//
//    var isExaminable: Bool
//
//    var examPaperSemester: Task.ExamSemester?
//
//    var examPaperYear: Int?
//
//    mutating func validate() throws {
//        guard !question.isEmpty else {
//            throw Abort(.badRequest)
//        }
//        guard let solution = solution, !solution.isEmpty else {
//            throw Abort(.badRequest)
//        }
//        examPaperYear = nil
//        examPaperSemester = nil
//        isExaminable = false
//    }
//}
