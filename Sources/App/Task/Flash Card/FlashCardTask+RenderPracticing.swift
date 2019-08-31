//
//  FlashCardTask+RenderPracticing.swift
//  App
//
//  Created by Mats Mollestad on 21/04/2019.
//

import Vapor
import KognitaCore
import KognitaViews

extension FlashCardTask: RenderTaskPracticing, TaskRenderable {

    func render(_ session: PracticeSession, for user: User, on req: Request) throws -> EventLoopFuture<HTTPResponse> {
        
        return FlashCardTask.repository
            .content(for: self, on: req)
            .flatMap { preview in

                try PracticeSession.repository
                    .getNextTaskPath(for: session, on: req)
                    .flatMap { nextPath in

                        try PracticeSession.repository
                            .goalProgress(in: session, on: req)
                            .flatMap { progress in

                                try PracticeSession.repository
                                    .getNumberOfTasks(in: session, on: req)
                                    .flatMap { numberOfTasks in

                                        try TaskResultRepository.shared
                                            .getLastResult(for: preview.task.requireID(), by: user, on: req)
                                            .map { lastResult in

                                                try req.renderer()
                                                    .render(
                                                        FlashCardTaskTemplate.self,
                                                        with: .init(
                                                            taskPreview: preview,
                                                            user: user,
                                                            nextTaskPath: nextPath,
                                                            practiceProgress: progress,
                                                            session: session,
                                                            lastResult: lastResult?.content,
                                                            numberOfTasks: numberOfTasks
                                                        )
                                                )
                                        }
                                }
                        }
                }
        }
    }

    func render(for user: User, on req: Request) throws -> Future<HTTPResponse> {

        return FlashCardTask.repository
            .content(for: self, on: req)
            .flatMap { preview in

                try TaskResultRepository.shared
                    .getLastResult(for: preview.task.requireID(), by: user, on: req)
                    .map { lastResult in

                        try req.renderer().render(
                            FlashCardTaskTemplate.self,
                            with: .init(
                                taskPreview: preview,
                                user: user,
                                lastResult: lastResult?.content,
                                numberOfTasks: 1
                            )
                        )
                }
        }
    }
}
