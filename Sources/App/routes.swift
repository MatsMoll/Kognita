import Crypto
import Vapor
import Authentication
import KognitaCore
import KognitaViews

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    try setupApi(for: router.grouped("api"))
    try setupWeb(for: router)
}

private func setupWeb(for route: Router) throws {
    try setupUserWeb(for: route)
}

private func setupUserWeb(for router: Router) throws {

    let sessionMiddle = router.grouped(User.authSessionsMiddleware())
    let redirectMiddle = sessionMiddle.grouped(RedirectMiddleware<User>(path: "/login"))

    router.get("/") { req in
        try req.renderer()
            .render(StarterPage.self, with: .init())
    }

    try sessionMiddle.register(collection: UserWebController())
    try redirectMiddle.register(collection: SubjectWebController())
    try redirectMiddle.register(collection: TopicWebController())
    try redirectMiddle.register(collection: MultipleChoiseTaskWebController())
    try redirectMiddle.register(collection: NumberInputTaskWebController())
    try redirectMiddle.register(collection: CreatorWebController())
    try redirectMiddle.register(collection: FlashCardTaskWebController())
    try redirectMiddle.register(collection: SubtopicWebController())

    redirectMiddle.get(
        "practice-sessions/", PracticeSession.parameter, "tasks", Int.parameter,
        use: PracticeSessionController.shared.renderCurrentTask)
    
    redirectMiddle.get(
        "practice-sessions/", PracticeSession.parameter, "result",
        use: PracticeSessionController.shared.getSessionResult)

    redirectMiddle.get(
        "practice-sessions/history",
        use: PracticeSessionController.shared.getSessions)
}

private func setupApi(for router: Router) throws {

    let authMiddleware = router.grouped(
        User.tokenAuthMiddleware(), User.authSessionsMiddleware(), User.guardAuthMiddleware()
    )

    try router.register(collection: UserController())
    try authMiddleware.register(collection: SubjectController.shared)
    try authMiddleware.register(collection: TopicController.shared)
    try authMiddleware.register(collection: MultipleChoiseTaskController.shared)
    try authMiddleware.register(collection: PracticeSessionController.shared)
    try authMiddleware.register(collection: NumberInputTaskController())
    try authMiddleware.register(collection: FlashCardTaskController())
    try authMiddleware.register(collection: TaskResultController())
    try authMiddleware.register(collection: SubtopicController())
}
