//
//  FlashCardTask+RenderPracticing.swift
//  App
//
//  Created by Mats Mollestad on 21/04/2019.
//

import Vapor
import KognitaCore
import KognitaViews

extension FlashCardTask: RenderTaskPracticing {

    func render(in session: PracticeSession, index: Int, for user: UserContent, on req: Request) throws -> Future<HTTPResponse> {
        
        return FlashCardTask.Repository
            .content(for: self, on: req)
            .flatMap { preview in

                try PracticeSession.Repository
                    .goalProgress(in: session, on: req)
                    .flatMap { progress in

                        try TaskResultRepository
                            .getLastResult(for: preview.task.requireID(), by: user.userId, on: req)
                            .map { lastResult in

                                try req.renderer()
                                    .render(
                                        FlashCardTask.Templates.Execute.self,
                                        with: .init(
                                            taskPreview: preview,
                                            user: user,
                                            currentTaskIndex: index,
                                            practiceProgress: progress,
                                            session: session,
                                            lastResult: lastResult?.content,
                                            numberOfTasks: 0
                                        )
                                )
                        }
                }
        }
    }

//    func render(for user: User, on req: Request) throws -> Future<HTTPResponse> {
//
//        return FlashCardTask.Repository
//            .content(for: self, on: req)
//            .flatMap { preview in
//
//                try TaskResultRepository
//                    .getLastResult(for: preview.task.requireID(), by: user, on: req)
//                    .map { lastResult in
//
//                        try req.renderer().render(
//                            FlashCardTask.Templates.Execute.self,
//                            with: .init(
//                                taskPreview: preview,
//                                user: user,
//                                lastResult: lastResult?.content,
//                                numberOfTasks: 1
//                            )
//                        )
//                }
//        }
//    }
}
