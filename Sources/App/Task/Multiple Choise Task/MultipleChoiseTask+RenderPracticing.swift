//
//  MultipleChoiseTask+RenderPracticing.swift
//  App
//
//  Created by Mats Mollestad on 21/04/2019.
//

import Vapor
import KognitaCore
import KognitaViews

extension MultipleChoiseTask: RenderTaskPracticing {

    func render(in session: PracticeSessionRepresentable, index: Int, for user: UserContent, on req: Request) throws -> EventLoopFuture<HTTPResponse> {

        return try MultipleChoiseTask.DatabaseRepository
            .content(for: self, on: req)
            .flatMap { preview, content in

                try PracticeSession.DatabaseRepository
                    .goalProgress(in: session, on: req)
                    .flatMap { progress in

                        try TaskResult.DatabaseRepository
                            .getLastResult(for: preview.task.requireID(), by: user.userId, on: req)
                            .flatMap { lastResult in

                                if lastResult != nil {
                                    return try TaskSessionAnswer.DatabaseRepository
                                        .multipleChoiseAnswers(in: session.requireID(), taskID: content.task.requireID(), on: req)
                                        .map { selectedChoises in

                                            try req.renderer()
                                                .render(
                                                    MultipleChoiseTask.Templates.Execute.self,
                                                    with: .init(
                                                        multiple: content,
                                                        taskContent: preview,
                                                        user: user,
                                                        currentTaskIndex: index,
                                                        session: session,
                                                        lastResult: lastResult?.content,
                                                        practiceProgress: progress,
                                                        selectedChoises: selectedChoises.map { $0.choiseID }
                                                    )
                                            )
                                    }
                                } else {
                                    return req.future().map {
                                        try req.renderer()
                                            .render(
                                                MultipleChoiseTask.Templates.Execute.self,
                                                with: .init(
                                                    multiple: content,
                                                    taskContent: preview,
                                                    user: user,
                                                    currentTaskIndex: index,
                                                    session: session,
                                                    lastResult: lastResult?.content,
                                                    practiceProgress: progress
                                                )
                                        )
                                    }
                                }
                        }
                }
        }
    }
}
