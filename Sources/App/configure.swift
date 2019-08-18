import Authentication
import FluentPostgreSQL
import Vapor
import HTMLKit
import KognitaCore
import Lingo
import KognitaViews

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {

    // Register providers first
    try services.register(FluentPostgreSQLProvider())
    try services.register(AuthenticationProvider())
    try services.register(HTMLKitProvider())
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
    services.register(middlewares)

    setupDatabase(for: env, in: &services)

    let migrations = DatabaseMigrations.migrationConfig()
    services.register(migrations)

    // Needs to be after addMigrations(), because it relies on the tables created there
    if env == .testing {
        // Register the commands (used to reset the database)
        var commandConfig = CommandConfig()
        commandConfig.useFluentCommands()
        services.register(commandConfig)
    }

    try services.register(setupTemplates())
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
        var databaseName = Environment.get("DATABASE_DB") ?? "postgres"
        if enviroment == .testing {
            databaseName = "postgres"
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

//class KognitaMigrations {
//    static func migrationConfig() -> MigrationConfig {
//        var migrations = MigrationConfig()
//
//        // This needs to run before Task migration
//        migrations.add(migration: Task.ExamSemester.self, database: .psql)
//
//        migrations.add(model: User.self, database: .psql)
//        migrations.add(model: UserToken.self, database: .psql)
//        migrations.add(model: Subject.self, database: .psql)
//        migrations.add(model: Topic.self, database: .psql)
//        migrations.add(model: Task.self, database: .psql)
//        migrations.add(model: MultipleChoiseTask.self, database: .psql)
//        migrations.add(model: MultipleChoiseTaskChoise.self, database: .psql)
//        migrations.add(model: PracticeSession.self, database: .psql)
//        migrations.add(model: PracticeSessionTaskPivot.self, database: .psql)
//        migrations.add(model: PracticeSessionTopicPivot.self, database: .psql)
//        migrations.add(model: UserTopicLevel.self, database: .psql)
//        migrations.add(model: NumberInputTask.self, database: .psql)
//        migrations.add(model: FlashCardTask.self, database: .psql)
//        migrations.add(model: TaskResult.self, database: .psql)
//
//        return migrations
//    }
//
//    static func addVersionBumbMigration(_ migrations: inout MigrationConfig) {
//        // Add migrations here
////        migrations.add(migration: TaskExamPaperAtomicMigration.self, database: .psql)
////        migrations.add(migration: TaskCreatedAtUpdatedAtMigration.self, database: .psql)
////        migrations.add(migration: PSTaskPivotUnforgivingScoreMigration.self, database: .psql)
//    }
//}

private func registerRouter(in services: inout Services) throws {
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)
}

private func setupTemplates() throws -> HTMLRenderer {

    var renderer = HTMLRenderer()

    try renderer.registerLocalization(defaultLocale: "nb")

    // Starter
    try renderer.add(template: StarterPage())

    // Auth
    try renderer.add(template: LoginPage())
    try renderer.add(template: SignupPage())

    // Main User pages
    try renderer.add(template: SubjectListTemplate())
    try renderer.add(template: SubjectDetailTemplate())

    // Task Overview
    try renderer.add(template: TaskOverviewListTemplate())

    // Task Template
    try renderer.add(template: MultipleChoiseTaskTemplate())
    try renderer.add(template: NumberInputTaskTemplate())
    try renderer.add(template: FlashCardTaskTemplate())

    // Create Content
    try renderer.add(template: CreateSubjectPage())
    try renderer.add(template: CreateTopicPage())

    // Create Task Templates
    try renderer.add(template: CreateMultipleChoiseTaskPage())
    try renderer.add(template: CreateNumberInputTaskTemplate())
    try renderer.add(template: CreateFlashCardTaskTemplate())

    // Practice Session
    try renderer.add(template: PSResultTemplate())
    try renderer.add(template: PSHistoryTemplate())

    // Creator pages
    try renderer.add(template: CreatorInformationPage())
    try renderer.add(template: CreatorDashboard())
    try renderer.add(template: CreatorTopicPage())
    return renderer
}
