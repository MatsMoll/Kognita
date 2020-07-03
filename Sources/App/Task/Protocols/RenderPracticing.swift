//
//  RenderPracticing.swift
//  App
//
//  Created by Mats Mollestad on 22/01/2019.
//

import Vapor
import KognitaCore

/// A protocol for a task tha can be practiced on
protocol RenderTaskPracticing {

    /// Render a task in practice mode
    ///
    /// - Parameters:
    ///     - req:      The http request
    ///     - session:  The session object the task is rendered for
    ///     - user:     The user to render the task for
    ///
    /// - Returns:
    ///     A renderd `View` of the task
    func render(in sessionID: PracticeSession.ID, index: Int, for user: User, on req: Request) -> EventLoopFuture<Response>
}

extension PracticeSession.CurrentTask {
    func render(on req: Request) -> EventLoopFuture<Response> {
        task.render(in: sessionID, index: index, for: user, on: req)
    }
}

extension TaskType: RenderTaskPracticing {

    func render(in sessionID: PracticeSession.ID, index: Int, for user: User, on req: Request) -> EventLoopFuture<Response> {

        return req.repositories.topicRepository
            .topicFor(taskID: task.id)
            .flatMap { topic in

                req.repositories.subjectRepository
                    .subjectFor(topicID: topic.id)
                    .map { subject in

                        TaskPreviewContent(
                            subject: subject,
                            topic: topic,
                            task: self.task,
                            actionDescription: ""
                        )
                }
        }
        .flatMap { preview in

            req.repositories.taskResultRepository
                .getLastResult(for: self.taskID, by: user.id)
                .flatMap { lastResult in

                    req.repositories.practiceSessionRepository
                        .goalProgress(in: sessionID)
                        .flatMap { progress in

                            if let isMultipleSelect = self.isMultipleSelect {
                                return self.renderMultipleChoiceTask(
                                    sessionID: sessionID,
                                    preview: preview,
                                    isMultipleSelect: isMultipleSelect,
                                    lastResult: lastResult,
                                    taskIndex: index,
                                    progress: progress,
                                    user: user,
                                    on: req
                                )
                            } else {
                                return self.renderTypingTask(
                                    sessionID: sessionID,
                                    preview: preview,
                                    lastResult: lastResult,
                                    taskIndex: index,
                                    progress: progress,
                                    user: user,
                                    on: req
                                )
                            }
                    }
            }
        }
    }

    func renderMultipleChoiceTask(sessionID: PracticeSession.ID, preview: TaskPreviewContent, isMultipleSelect: Bool, lastResult: TaskResult?, taskIndex: Int, progress: Int, user: User, on req: Request) -> EventLoopFuture<Response> {
        req.eventLoop.future()
            .flatMap {
                if lastResult != nil {
                    return req.repositories.multipleChoiceTaskRepository
                        .multipleChoiseAnswers(in: sessionID, taskID: preview.task.id)
                        .map { answers in
                            MultipleChoiceTask.Templates.Execute.Context(
                                multiple: MultipleChoiceTask(
                                    task: preview.task,
                                    isMultipleSelect: isMultipleSelect,
                                    choices: answers.map { choice in
                                        MultipleChoiceTaskChoice.init(
                                            id: choice.id,
                                            choice: choice.choice,
                                            isCorrect: choice.isCorrect
                                        )
                                    }
                                ),
                                taskContent: preview,
                                user: user,
                                currentTaskIndex: taskIndex,
                                sessionID: sessionID,
                                lastResult: lastResult,
                                practiceProgress: progress,
                                selectedChoises: answers.filter { $0.wasSelected }.map { $0.id }
                            )
                    }
                } else {
                    return req.repositories.multipleChoiceTaskRepository.choisesFor(taskID: preview.task.id)
                        .map { choices in
                            MultipleChoiceTask.Templates.Execute.Context(
                                multiple: MultipleChoiceTask(
                                    task: preview.task,
                                    isMultipleSelect: isMultipleSelect,
                                    choices: choices
                                ),
                                taskContent: preview,
                                user: user,
                                currentTaskIndex: taskIndex,
                                sessionID: sessionID,
                                lastResult: lastResult,
                                practiceProgress: progress
                            )
                    }
                }
        }
        .flatMapThrowing { context in
            try req.htmlkit.render(MultipleChoiceTask.Templates.Execute.self, with: context)
        }
    }

    func renderTypingTask(sessionID: PracticeSession.ID, preview: TaskPreviewContent, lastResult: TaskResult?, taskIndex: Int, progress: Int, user: User, on req: Request) -> EventLoopFuture<Response> {
        req.repositories.typingTaskRepository
            .typingTaskAnswer(in: sessionID, taskID: preview.task.id)
            .map { answer in
                TypingTask.Templates.Execute.Context(
                    taskPreview: preview,
                    user: user,
                    currentTaskIndex: taskIndex,
                    practiceProgress: progress,
                    sessionID: sessionID,
                    lastResult: lastResult,
                    prevAnswer: answer
                )
            }
            .flatMapThrowing { try req.htmlkit.render(TypingTask.Templates.Execute.self, with: $0) }
    }
}
