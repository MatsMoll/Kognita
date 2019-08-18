//
//  MultipleChoiseTask+RenderPracticing.swift
//  App
//
//  Created by Mats Mollestad on 21/04/2019.
//

import Vapor
import KognitaCore
import KognitaViews

extension MultipleChoiseTask: RenderTaskPracticing, TaskRenderable {

    func render(_ session: PracticeSession, for user: User, on req: Request) throws -> Future<HTTPResponse> {

        return try MultipleChoiseTaskRepository.shared
            .content(for: self, on: req)
            .flatMap { preview, content in

                try PracticeSessionRepository.shared
                    .getNextTaskPath(for: session, on: req)
                    .flatMap { nextPath in

                        try PracticeSessionRepository.shared
                            .goalProgress(in: session, on: req)
                            .flatMap { progress in

                                try PracticeSessionRepository.shared
                                    .getNumberOfTasks(in: session, on: req)
                                    .flatMap { numberOfTasks in

                                        try TaskResultRepository.shared
                                            .getLastResult(for: preview.task.requireID(), by: user, on: req)
                                            .map { lastResult in

                                                try req.renderer()
                                                    .render(
                                                        MultipleChoiseTaskTemplate.self,
                                                        with: .init(
                                                            multiple: content,
                                                            taskContent: preview,
                                                            user: user,
                                                            nextTaskPath: nextPath,
                                                            session: session,
                                                            practiceProsess: progress,
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

        return try MultipleChoiseTaskRepository.shared
            .content(for: self, on: req)
            .flatMap { preview, content in

                try TaskResultRepository.shared
                    .getLastResult(for: preview.task.requireID(), by: user, on: req)
                    .map { lastResult in

                        try req.renderer().render(
                            MultipleChoiseTaskTemplate.self,
                            with: .init(
                                multiple: content,
                                taskContent: preview,
                                user: user,
                                lastResult: lastResult?.content,
                                numberOfTasks: 1
                            )
                        )
                }
        }
    }
}
