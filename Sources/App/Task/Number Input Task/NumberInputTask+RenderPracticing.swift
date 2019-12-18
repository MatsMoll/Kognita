//
//  NumberInputTask+RenderPracticing.swift
//  App
//
//  Created by Mats Mollestad on 21/04/2019.
//

import Vapor
import KognitaCore
import KognitaViews

extension NumberInputTask: RenderTaskPracticing {
    func render(in session: PracticeSession, index: Int, for user: UserContent, on req: Request) throws -> EventLoopFuture<HTTPResponse> {

        return try NumberInputTask.Repository
            .content(for: self, on: req)
            .flatMap { preview, content in

                try PracticeSession.Repository
                    .goalProgress(in: session, on: req)
                    .flatMap { progress in

                        try TaskResultRepository
                            .getLastResult(for: preview.task.requireID(), by: user.userId, on: req)
                            .map { lastResult in

                                try req.renderer()
                                    .render(
                                        NumberInputTask.Templates.Execute.self,
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
}
