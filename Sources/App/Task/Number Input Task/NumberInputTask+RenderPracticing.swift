//
//  NumberInputTask+RenderPracticing.swift
//  App
//
//  Created by Mats Mollestad on 21/04/2019.
//

import Vapor
import KognitaCore
import KognitaViews

extension NumberInputTask: RenderTaskPracticing, TaskRenderable {
    func render(in session: PracticeSession, index: Int, for user: User, on req: Request) throws -> EventLoopFuture<HTTPResponse> {

        return try NumberInputTask.repository
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
                                        NumberInputTaskTemplate.self,
                                        with: .init(
                                            numberTask: content,
                                            taskPreview: preview,
                                            user: user,
                                            currentTaskIndex: index,
                                            session: session,
                                            practiceProgress: progress,
                                            lastResult: lastResult?.content
                                        )
                                )
                        }
                }
        }
    }

    func render(for user: User, on req: Request) throws -> Future<HTTPResponse> {

        return try NumberInputTask.repository
            .content(for: self, on: req)
            .flatMap { preview, content in

                try TaskResultRepository.shared
                    .getLastResult(for: preview.task.requireID(), by: user, on: req)
                    .map { lastResult in

                        try req.renderer().render(
                            NumberInputTaskTemplate.self,
                            with: .init(
                                numberTask: content,
                                taskPreview: preview,
                                user: user,
                                currentTaskIndex: nil,
                                lastResult: lastResult?.content
                            )
                        )
                }
        }
    }
}
