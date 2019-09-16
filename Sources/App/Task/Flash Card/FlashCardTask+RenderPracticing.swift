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

    func render(in session: PracticeSession, index: Int, for user: User, on req: Request) throws -> Future<HTTPResponse> {
        
        return FlashCardTask.repository
            .content(for: self, on: req)
            .flatMap { preview in

                try PracticeSession.repository
                    .goalProgress(in: session, on: req)
                    .flatMap { progress in

                        try TaskResultRepository.shared
                            .getLastResult(for: preview.task.requireID(), by: user, on: req)
                            .map { lastResult in

                                try req.renderer()
                                    .render(
                                        FlashCardTaskTemplate.self,
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
