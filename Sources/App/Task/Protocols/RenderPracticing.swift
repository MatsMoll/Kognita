//
//  RenderPracticing.swift
//  App
//
//  Created by Mats Mollestad on 22/01/2019.
//

import Vapor
import KognitaCore
//swiftlint:disable function_parameter_count

extension Sessions.CurrentTask {
    func renderPracticeSession(on req: Request) -> EventLoopFuture<Response> {
        task.renderPractice(sessionID: sessionID, index: index, for: user, on: req)
    }

    func renderExamSession(on req: Request) -> EventLoopFuture<View> {
        task.renderExam(sessionID: sessionID, index: index, for: user, on: req)
    }
}

extension TaskType {

    func taskPreviewContent(sessionID: Sessions.ID, index: Int, repositories: RepositoriesRepresentable) -> EventLoopFuture<TaskPreviewContent> {
        repositories.topicRepository
            .topicFor(taskID: task.id)
            .flatMap { topic in

                repositories.subjectRepository
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
    }

    func progressStateForPractice(sessionID: Sessions.ID, index: Int, repositories: RepositoriesRepresentable) -> EventLoopFuture<Sessions.ProgressState> {

        repositories.practiceSessionRepository
            .find(sessionID)
            .flatMap { session in

                repositories.practiceSessionRepository
                    .goalProgress(in: sessionID)
                    .map { progress in

                        Sessions.ProgressState(
                            progress: progress,
                            numberOfTaskGoal: session.numberOfTaskGoal,
                            currentTaskIndex: index,
                            sessionID: sessionID
                        )
                    }
            }
    }

    func progressStateForExam(sessionID: Sessions.ID, index: Int, repositories: RepositoriesRepresentable) -> EventLoopFuture<Sessions.ProgressState> {

        repositories.examSessionRepository
            .find(sessionID)
            .flatMap { session in

                repositories.examSessionRepository
                    .goalProgress(in: sessionID)
                    .map { progress in

                        Sessions.ProgressState(
                            progress: progress,
                            numberOfTaskGoal: session.numberOfTaskGoal,
                            currentTaskIndex: index,
                            sessionID: sessionID
                        )
                    }
            }
    }

    func renderPractice(sessionID: PracticeSession.ID, index: Int, for user: User, on req: Request) -> EventLoopFuture<Response> {

        req.repositories { repositories in
            taskPreviewContent(sessionID: sessionID, index: index, repositories: repositories)
                .flatMap { preview in

                    progressStateForPractice(sessionID: sessionID, index: index, repositories: repositories)
                        .flatMap { progressState in

                            repositories.taskResultRepository
                                .getLastResult(for: self.taskID, by: user.id)
                                .flatMap { lastResult in

                                    if let isMultipleSelect = self.isMultipleSelect {
                                        return self.renderPracticeMultipleChoiceTask(
                                            progressState: progressState,
                                            preview: preview,
                                            isMultipleSelect: isMultipleSelect,
                                            lastResult: lastResult,
                                            user: user,
                                            repositories: repositories,
                                            on: req
                                        )
                                    } else {
                                        return self.renderPracticeTypingTask(
                                            progressState: progressState,
                                            preview: preview,
                                            lastResult: lastResult,
                                            user: user,
                                            repositories: repositories,
                                            on: req
                                        )
                                    }
                                }
                        }
                }
        }
    }

    func renderPracticeMultipleChoiceTask(progressState: Sessions.ProgressState, preview: TaskPreviewContent, isMultipleSelect: Bool, lastResult: TaskResult?, user: User, repositories: RepositoriesRepresentable, on req: Request) -> EventLoopFuture<Response> {

        req.eventLoop.future()
            .flatMap {
                if lastResult != nil {
                    return repositories.multipleChoiceTaskRepository
                        .multipleChoiseAnswers(in: progressState.sessionID, taskID: preview.task.id)
                        .map { answers in
                            PracticeSession.Templates.ExecuteMultipleChoice.Context(
                                multiple: MultipleChoiceTask(
                                    task: preview.task,
                                    isMultipleSelect: isMultipleSelect,
                                    choices: answers.map { choice in
                                        MultipleChoiceTaskChoice.init(
                                            id: choice.id,
                                            choice: choice.choice,
                                            isCorrect: choice.isCorrect
                                        )
                                    }.shuffled()
                                ),
                                taskContent: preview,
                                user: user,
                                lastResult: lastResult,
                                selectedChoises: answers.filter { $0.wasSelected }.map { $0.id },
                                progressState: progressState
                            )
                    }
                } else {
                    return repositories.multipleChoiceTaskRepository
                        .choisesFor(taskID: preview.task.id)
                        .map { choices in
                            PracticeSession.Templates.ExecuteMultipleChoice.Context(
                                multiple: MultipleChoiceTask(
                                    task: preview.task,
                                    isMultipleSelect: isMultipleSelect,
                                    choices: choices.shuffled()
                                ),
                                taskContent: preview,
                                user: user,
                                lastResult: lastResult,
                                progressState: progressState
                            )
                    }
                }
        }
        .flatMapThrowing { context in
            try req.htmlkit.render(PracticeSession.Templates.ExecuteMultipleChoice.self, with: context)
        }
    }

    func renderPracticeTypingTask(progressState: Sessions.ProgressState, preview: TaskPreviewContent, lastResult: TaskResult?, user: User, repositories: RepositoriesRepresentable, on req: Request) -> EventLoopFuture<Response> {

        repositories.typingTaskRepository
            .typingTaskAnswer(in: progressState.sessionID, taskID: preview.task.id)
            .map { answer in
                PracticeSession.Templates.ExecuteTypingTask.Context(
                    taskPreview: preview,
                    user: user,
                    lastResult: lastResult,
                    prevAnswer: answer,
                    progressState: progressState
                )
            }
            .flatMapThrowing { try req.htmlkit.render(PracticeSession.Templates.ExecuteTypingTask.self, with: $0) }
    }
}

extension TaskType {

    func renderExam(sessionID: PracticeSession.ID, index: Int, for user: User, on req: Request) -> EventLoopFuture<View> {

        req.repositories { repositories in
            taskPreviewContent(sessionID: sessionID, index: index, repositories: repositories)
                .flatMap { preview in

                    progressStateForExam(sessionID: sessionID, index: index, repositories: repositories)
                        .flatMap { progressState in

                            repositories.taskResultRepository
                                .getLastResult(for: self.taskID, by: user.id)
                                .flatMap { lastResult in

                                    if let isMultipleSelect = self.isMultipleSelect {
                                        return self.renderExamMultipleChoiceTask(
                                            progressState: progressState,
                                            preview: preview,
                                            isMultipleSelect: isMultipleSelect,
                                            lastResult: lastResult,
                                            user: user,
                                            repositories: repositories,
                                            on: req
                                        )
                                    } else {
                                        return self.renderExamTypingTask(
                                            progressState: progressState,
                                            preview: preview,
                                            lastResult: lastResult,
                                            user: user,
                                            repositories: repositories,
                                            on: req
                                        )
                                    }
                                }
                        }
                }
        }
    }

    func renderExamMultipleChoiceTask(progressState: Sessions.ProgressState, preview: TaskPreviewContent, isMultipleSelect: Bool, lastResult: TaskResult?, user: User, repositories: RepositoriesRepresentable, on req: Request) -> EventLoopFuture<View> {

        req.eventLoop.future()
            .flatMap {
                if lastResult != nil {
                    return repositories.multipleChoiceTaskRepository
                        .multipleChoiseAnswers(in: progressState.sessionID, taskID: preview.task.id)
                        .map { answers in
                            ExamSession.Templates.ExecuteMultipleChoice.Context(
                                multiple: MultipleChoiceTask(
                                    task: preview.task,
                                    isMultipleSelect: isMultipleSelect,
                                    choices: answers.map { choice in
                                        MultipleChoiceTaskChoice.init(
                                            id: choice.id,
                                            choice: choice.choice,
                                            isCorrect: choice.isCorrect
                                        )
                                    }.shuffled()
                                ),
                                taskContent: preview,
                                user: user,
                                lastResult: lastResult,
                                selectedChoises: answers.filter { $0.wasSelected }.map { $0.id },
                                progressState: progressState
                            )
                    }
                } else {
                    return repositories.multipleChoiceTaskRepository
                        .choisesFor(taskID: preview.task.id)
                        .map { choices in
                            ExamSession.Templates.ExecuteMultipleChoice.Context(
                                multiple: MultipleChoiceTask(
                                    task: preview.task,
                                    isMultipleSelect: isMultipleSelect,
                                    choices: choices.shuffled()
                                ),
                                taskContent: preview,
                                user: user,
                                lastResult: lastResult,
                                progressState: progressState
                            )
                    }
                }
        }
        .flatMap { context in
            ExamSession.Templates.ExecuteMultipleChoice().render(with: context, for: req)
        }
    }

    func renderExamTypingTask(progressState: Sessions.ProgressState, preview: TaskPreviewContent, lastResult: TaskResult?, user: User, repositories: RepositoriesRepresentable, on req: Request) -> EventLoopFuture<View> {

        repositories.typingTaskRepository
            .typingTaskAnswer(in: progressState.sessionID, taskID: preview.task.id)
            .map { answer in
                ExamSession.Templates.ExecuteTypingTask.Context(
                    taskPreview: preview,
                    user: user,
                    lastResult: lastResult,
                    prevAnswer: answer,
                    progressState: progressState
                )
            }
            .flatMap { ExamSession.Templates.ExecuteTypingTask().render(with: $0, for: req) }
    }
}
