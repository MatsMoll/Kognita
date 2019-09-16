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

    func render(in session: PracticeSession, index: Int, for user: User, on req: Request) throws -> EventLoopFuture<HTTPResponse> {

        return try MultipleChoiseTask.repository
            .content(for: self, on: req)
            .flatMap { preview, content in

                try PracticeSession.repository
                    .goalProgress(in: session, on: req)
                    .flatMap { progress in

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
                                            currentTaskIndex: index,
                                            session: session,
                                            practiceProsess: progress,
                                            lastResult: lastResult?.content
                                        )
                                )
                        }
                }
        }
    }

    func render(for user: User, on req: Request) throws -> Future<HTTPResponse> {

        return try MultipleChoiseTask.repository
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
                                lastResult: lastResult?.content
                            )
                        )
                }
        }
    }
}
