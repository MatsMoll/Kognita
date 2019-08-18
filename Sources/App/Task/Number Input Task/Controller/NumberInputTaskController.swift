//
//  NumberInputTaskController.swift
//  App
//
//  Created by Mats Mollestad on 23/03/2019.
//

import Vapor
import KognitaCore

class NumberInputTaskController: CRUDControllable, RouteCollection {

    var parameter: PathComponentsRepresentable { return NumberInputTask.parameter }

    func boot(router: Router) {
        router.register(
            controller: self,
            at: "tasks/input")
        router.post(
            "tasks/input", NumberInputTask.parameter,
            use: submitAnswer)
    }

    func getInstance(_ req: Request) throws -> EventLoopFuture<NumberInputTaskContent> {
        return try req.parameters
            .next(NumberInputTask.self)

            .flatMap { inputTask in
                try NumberInputTaskRepository.shared
                    .get(task: inputTask, conn: req)
        }
    }

    func getInstanceCollection(_ req: Request) throws -> EventLoopFuture<[NumberInputTaskContent]> {
        return NumberInputTask.query(on: req)
            .all()
            .flatMap { tasks in

                return try tasks.map {
                    try NumberInputTaskRepository.shared
                        .get(task: $0, conn: req)
                    }.flatten(on: req)
        }
    }

    func create(_ req: Request) throws -> EventLoopFuture<NumberInputTaskContent> {
        let user = try req.requireAuthenticated(User.self)

        return try req.content
            .decode(NumberInputTaskCreateContent.self)
            .flatMap { content in

                try NumberInputTaskRepository.shared
                    .create(with: content, user: user, conn: req)
                    .flatMap { task in
                        try NumberInputTaskRepository.shared
                            .get(task: task, conn: req)
                }
        }
    }

    func delete(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {

        let user = try req.requireAuthenticated(User.self)

        return try req.parameters
            .next(NumberInputTask.self)
            .flatMap { inputTask in

                try NumberInputTaskRepository.shared
                    .delete(task: inputTask, user: user, conn: req)
                    .transform(to: .ok)
        }
    }

    func edit(_ req: Request) throws -> EventLoopFuture<NumberInputTaskContent> {

        let user = try req.requireAuthenticated(User.self)

        return try req.content
            .decode(NumberInputTaskCreateContent.self)
            .flatMap { content in

            return try req.parameters
                .next(NumberInputTask.self)
                .flatMap { inputTask in

                    try NumberInputTaskRepository.shared
                        .edit(task: inputTask, with: content, user: user, conn: req)
                        .flatMap { task in
                            try NumberInputTaskRepository.shared
                                .get(task: task, conn: req)
                    }
            }

        }
    }

    func submitAnswer(_ req: Request) throws -> Future<PracticeSessionResult<NumberInputTaskSubmitResponse>> {

        throw Abort(.internalServerError)
//        return try req.content.decode(NumberInputTaskSubmit.self).flatMap { submit in
//            try req.parameters.next(NumberInputTask.self).map { task in
//                task.evaluate(for: submit)
//            }
//        }
    }
}

//struct NumberInputTaskCreateContent: Content, TaskCreationContentable {
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
//    let examPaper: String?
//
//    let examPaperYear: Int?
//
//    let examPaperSemester: Task.ExamSemester?
//
//    let isExaminable: Bool
//
//    let correctAnswer: Double
//
//    let unit: String?
//}
