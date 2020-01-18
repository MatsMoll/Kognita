import Crypto
import Vapor
import Authentication
import KognitaCore
import KognitaViews
import HTMLKit
import KognitaAPI

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    try setupWeb(for: router)
}

private func setupWeb(for route: Router) throws {
    try setupUserWeb(for: route)
}

private func setupUserWeb(for router: Router) throws {

    let sessionMiddle = router.grouped(User.authSessionsMiddleware())
    let redirectMiddle = sessionMiddle.grouped(RedirectMiddleware<User>(path: "/login"))

    router.get("/") { req in
        try req.renderer().render(view: Pages.Landing.self)
    }
    router.get("/privacy-policy") { req in
        try req.renderer().render(view: Pages.PrivacyPolicy.self)
    }
    router.get("/terms-of-usage") { req in
        try req.renderer().render(view: Pages.TermsOfUsage.self)
    }

    try sessionMiddle.register(collection: UserWebController())
    try redirectMiddle.register(collection: SubjectWebController())
    try redirectMiddle.register(collection: TopicWebController())
    try redirectMiddle.register(collection: MultipleChoiseTaskWebController())
//    try redirectMiddle.register(collection: NumberInputTaskWebController())
    try redirectMiddle.register(collection: CreatorWebController())
    try redirectMiddle.register(collection: FlashCardTaskWebController())
    try redirectMiddle.register(collection: SubtopicWebController())
    try redirectMiddle.register(collection: PracticeSessionWebController())
    try redirectMiddle.register(collection: SubjectTestWebController<SubjectTestAPIController<SubjectTest.DatabaseRepository>>())
    try redirectMiddle.register(collection: TestSessionWebController())
}
