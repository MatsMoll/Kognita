import Authentication
import FluentPostgreSQL
import Vapor
import HTMLKit
import HTMLKitVapor
import KognitaCore
import KognitaViews
import Mailgun

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {

    // Register providers first
    try services.register(FluentPostgreSQLProvider())
    try services.register(AuthenticationProvider())
//    try services.register(HTMLKitProvider())
    let connectionConfig = DatabaseConnectionPoolConfig(maxConnections: 3)
    services.register(connectionConfig)

    // Sets the templating framework and Web Sessions
    config.prefer(MemoryKeyedCache.self, for: KeyedCache.self)

    try registerRouter(in: &services)

    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    middlewares.use(SessionsMiddleware.self) // Enables sessions.
    middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    if env != .production {
        middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    }
    /// In order to upload big files
    services.register(NIOServerConfig.default(maxBodySize: 20_000_000))
    services.register(middlewares)

    setupDatabase(for: env, in: &services)

    let migrations = DatabaseMigrations.migrationConfig(enviroment: env)
    services.register(migrations)

    // Needs to be after addMigrations(), because it relies on the tables created there
    if env == .testing {
        // Register the commands (used to reset the database)
        var commandConfig = CommandConfig()
        commandConfig.useFluentCommands()
        services.register(commandConfig)
    }
    try services.register(setupTemplates())
    setupMailgun(in: &services)
}

private func setupMailgun(in services: inout Services) {
    guard let mailgunKey = Environment.get("MAILGUN_KEY"),
        let mailgunDomain = Environment.get("MAILGUN_DOMAIN") else {
            print("Mailgun is NOT activated")
            return
    }
    let mailgun = Mailgun(apiKey: mailgunKey, domain: mailgunDomain, region: .eu)
    services.register(mailgun, as: Mailgun.self)
}

private func setupDatabase(for enviroment: Environment, in services: inout Services) {

    // Configure a PostgreSQL database
    let databaseConfig: PostgreSQLDatabaseConfig!

    let hostname = Environment.get("DATABASE_HOSTNAME") ?? "localhost"
    let username = Environment.get("DATABASE_USER") ?? "postgres"

    if let url = Environment.get("DATABASE_URL") {  // Heroku
        guard let psqlConfig = PostgreSQLDatabaseConfig(url: url, transport: .unverifiedTLS) else {
            fatalError("Failed to create PostgreSQL Config")
        }
        databaseConfig = psqlConfig
    } else {                                        // Localy testing
        var databaseName = "local"
        if let customName = Environment.get("DATABASE_DB") {
            databaseName = customName
        } else if enviroment == .testing {
            databaseName = "testing"
        }
        let databasePort = 5432
        let password = Environment.get("DATABASE_PASSWORD") ?? nil
        databaseConfig = PostgreSQLDatabaseConfig(
            hostname: hostname,
            port: databasePort,
            username: username,
            database: databaseName,
            password: password
        )
    }

    let postgres = PostgreSQLDatabase(config: databaseConfig)

    // Register the configured PostgreSQL database to the database config.
    var databases = DatabasesConfig()
    databases.enableLogging(on: .psql)
    databases.add(database: postgres, as: .psql)
    services.register(databases)
}

private func registerRouter(in services: inout Services) throws {
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)
}

func setupTemplates() throws -> HTMLRenderer {

    let renderer = HTMLRenderer()

    let path = DirectoryConfig.detect().workDir + "Resources/Localization"
    try renderer.registerLocalization(atPath: path, defaultLocale: "nb")
//
//    // Starter
    try renderer.add(view: Pages.Landing())
//
//    // Auth
    try renderer.add(view: LoginPage())
    try renderer.add(view: User.Templates.Signup())
    try renderer.add(view: User.Templates.ResetPassword.Start())
    try renderer.add(view: User.Templates.ResetPassword.Mail())
    try renderer.add(view: User.Templates.ResetPassword.Reset())
//
//    // Main User pages
    try renderer.add(view: Subject.Templates.ListOverview())
    try renderer.add(view: Subject.Templates.Details())
    try renderer.add(view: Subject.Templates.SelectRedirect())
//
//    // Task Overview
//    try renderer.add(template: TaskOverviewListTemplate())
//
//    // Task Template
    try renderer.add(view: FlashCardTask.Templates.Execute())
    try renderer.add(view: MultipleChoiseTask.Templates.Execute())
    try renderer.add(view: NumberInputTask.Templates.Execute())
    try renderer.add(view: TaskSolutionsTemplate())
//
//    // Create Content
    try renderer.add(view: Subject.Templates.Create())
    try renderer.add(view: Topic.Templates.Create())
    try renderer.add(view: Subtopic.Templates.Create())
//
//    // Create Task Templates
    try renderer.add(view: FlashCardTask.Templates.Create())
    try renderer.add(view: MultipleChoiseTask.Templates.Create())
    try renderer.add(view: NumberInputTask.Templates.Create())
//
//    // Practice Session
    try renderer.add(view: PracticeSession.Templates.History())
    try renderer.add(view: PracticeSession.Templates.Result())

//    // Creator pages
    try renderer.add(view: CreatorTemplates.Dashboard())
    try renderer.add(view: CreatorTemplates.TopicDetails())
//    try renderer.add(template: CreatorInformationPage())
    return renderer
}
