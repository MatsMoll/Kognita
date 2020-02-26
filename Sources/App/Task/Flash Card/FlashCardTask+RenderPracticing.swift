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

    func render(in session: PracticeSessionRepresentable, index: Int, for user: UserContent, on req: Request) throws -> Future<HTTPResponse> {
        
        return FlashCardTask.DatabaseRepository
            .content(for: self, on: req)
            .flatMap { preview in

                try TaskSessionAnswer.DatabaseRepository
                    .flashCardAnswers(in: session.requireID(), taskID: preview.task.requireID(), on: req)
                    .flatMap { answer in

                        try PracticeSession.DatabaseRepository
                            .goalProgress(in: session, on: req)
                            .flatMap { progress in

                                try TaskResult.DatabaseRepository
                                    .getLastResult(for: preview.task.requireID(), by: user.userId, on: req)
                                    .flatMap { lastResult in

                                        try TaskDiscussion.DatabaseRepository
                                            .getDiscussions(in: preview.task.requireID(), on: req)
                                            .map { discussions in

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
                                                            prevAnswer: answer,
                                                            discussions: discussions
                                                        )
                                                )
                                        }
                                }
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
