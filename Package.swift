// swift-tools-version:5.2
import PackageDescription
import Foundation

var dependencies: [Package.Dependency] = [
    // 💧 A server-side Swift web framework.
    .package(name: "vapor", url: "https://github.com/vapor/vapor.git", from: "4.29.0"),

    .package(name: "HTMLKitVaporProvider", url: "https://github.com/MatsMoll/htmlkit-vapor-provider.git", from: "1.0.1"),
    
    .package(url: "https://github.com/vapor-community/HTMLKit.git", from: "2.1.0"),
]

// Kognita Core

switch ProcessInfo.processInfo.environment["BUILD_TYPE"] {
case "LOCAL":
    dependencies.append(contentsOf: [
            .package(path: "../KognitaAPI"),
            .package(path: "../KognitaCore"),
            .package(path: "../KognitaViews")
        ]
    )
case "DEV":
    dependencies.append(contentsOf: [
        .package(name: "KognitaCore", url: "https://Kognita:dyjdov-bupgev-goffY8@github.com/MatsMoll/KognitaCore", .branch("develop")),
        .package(name: "KognitaViews", url: "https://Kognita:dyjdov-bupgev-goffY8@github.com/MatsMoll/KognitaPages", .branch("develop")),
        .package(name: "KognitaAPI", url: "https://Kognita:dyjdov-bupgev-goffY8@github.com/MatsMoll/kognita-rest-api", .branch("develop"))
        ]
    )
default:
    #if os(macOS)
    if ProcessInfo.processInfo.environment["CUSTOM_SETTINGS"] == nil {
        dependencies.append(contentsOf: [
                .package(path: "../KognitaAPI"),
                .package(path: "../KognitaCore"),
                .package(path: "../KognitaViews"),
                .package(path: "../KognitaModels")
            ]
        )
        break
    }
    #endif
    let coreVersion     = ProcessInfo.processInfo.environment["KOGNITA_CORE"]   ?? "2.0.0"
    let pagesVersion    = ProcessInfo.processInfo.environment["KOGNITA_PAGES"]  ?? "2.0.0"
    let apiVersion      = ProcessInfo.processInfo.environment["KOGNITA_API"]    ?? "2.0.0"
    dependencies.append(contentsOf: [
        .package(name: "KognitaCore", url: "https://Kognita:dyjdov-bupgev-goffY8@github.com/MatsMoll/KognitaCore", from: Version(stringLiteral: coreVersion)),
        .package(name: "KognitaViews", url: "https://Kognita:dyjdov-bupgev-goffY8@github.com/MatsMoll/KognitaPages", from: Version(stringLiteral: pagesVersion)),
        .package(name: "KognitaAPI", url: "https://Kognita:dyjdov-bupgev-goffY8@github.com/MatsMoll/kognita-rest-api", from: Version(stringLiteral: apiVersion))
        ]
    )
}

let package = Package(
    name: "Kognita",
    platforms: [
        .macOS(.v10_15)
    ],
    dependencies: dependencies,
    targets: [
        .target(name: "App", dependencies: [
            .product(name: "Vapor", package: "vapor"),
            .product(name: "KognitaCore", package: "KognitaCore"),
            .product(name: "KognitaViews", package: "KognitaViews"),
            .product(name: "KognitaAPI", package: "KognitaAPI"),
            .product(name: "HTMLKitVaporProvider", package: "HTMLKitVaporProvider")
        ]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: [
            .target(name: "App"),
            .product(name: "KognitaCoreTestable", package: "KognitaCore"),
            .product(name: "XCTVapor", package: "vapor")
        ])
    ]
)
