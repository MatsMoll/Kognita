//
//  HTMLRendererLogger.swift
//  App
//
//  Created by Mats Mollestad on 21/11/2020.
//

import HTMLKit
import Vapor
import Metrics
import KognitaViews

class HTMLRendererLogger: HTMLRenderable {

    static let durationLabel = "html_renderer_duration"

    let renderer: HTMLRenderer
    let metricsFactory: MetricsFactory

    init(renderer: HTMLRenderer, metricsFactory: MetricsFactory) {
        self.renderer = renderer
        self.metricsFactory = metricsFactory
    }

    func render<T>(raw type: T.Type, with context: T.Context) throws -> String where T: HTMLTemplate {
        let start = Date()
        defer {
            let template = String(reflecting: T.self)
            metricsFactory.makeTimer(
                label: HTMLRendererLogger.durationLabel,
                dimensions: [
                    ("template", template)
                ]
            )
            .recordNanoseconds(Int64(Date().timeIntervalSince(start) * 1000))
        }
        return try renderer.render(raw: T.self, with: context)
    }

    func render<T>(raw type: T.Type) throws -> String where T: HTMLPage {
        let start = Date()
        defer {
            let page = String(reflecting: T.self)
            metricsFactory.makeTimer(
                label: HTMLRendererLogger.durationLabel,
                dimensions: [
                    ("page", page)
                ]
            )
            .recordNanoseconds(Int64(Date().timeIntervalSince(start) * 1000))
        }
        return try renderer.render(raw: T.self)
    }

    func add<T>(view: T) throws where T: HTMLPage {
        try renderer.add(view: view)
    }

    func add<T>(view: T) throws where T: HTMLTemplate {
        try renderer.add(view: view)
    }

    func registerLocalization(atPath path: String, defaultLocale: String) throws {
        try renderer.registerLocalization(atPath: path, defaultLocale: defaultLocale)
    }
}

struct HTMLKitLifecycle: LifecycleHandler {

    let rootUrl: String

    func willBoot(_ app: Application) throws {
        app.htmlkit.localizationPath = app.directory.workingDirectory + "Resources/Localization"
        app.htmlkit.defaultLocale = "nb"

        let renderer = HTMLRenderer()
        try KognitaViews.renderer(rootURL: rootUrl, renderer: renderer)
        app.htmlkit.renderer = HTMLRendererLogger(renderer: renderer, metricsFactory: MetricsSystem.factory)

        app.verifyEmailRenderer.use { VerifyEmailRenderer(renderer: $0.htmlkit) }
        app.resetPasswordRenderer.use { ResetPasswordMailRenderer(renderer: $0.htmlkit) }
    }
}
