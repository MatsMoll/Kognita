// swift-tools-version:5.1
import PackageDescription
import Foundation

var dependencies: [Package.Dependency] = [
    // 💧 A server-side Swift web framework.
    .package(url: "https://github.com/vapor/vapor.git", from: "3.3.1"),

    // Encodes Form requests
    .package(url: "https://github.com/vapor/url-encoded-form.git", from: "1.0.0"),

    .package(url: "https://github.com/MatsMoll/htmlkit-vapor-3-provider.git", from: "1.0.0-beta.3"),
]


// Kognita Core

switch ProcessInfo.processInfo.environment["BUILD_TYPE"] {
case "LOCAL":
    dependencies.append(contentsOf: [
            .package(path: "../KognitaAPI"),
            .package(path: "../KognitaCore"),
            .package(path: "../KognitaViews"),
        ]
    )
case "DEV":
    let coreBranch     = ProcessInfo.processInfo.environment["KOGNITA_CORE"]   ?? "develop"
    let pagesBranch    = ProcessInfo.processInfo.environment["KOGNITA_PAGES"]  ?? "develop"
    let apiBranch      = ProcessInfo.processInfo.environment["KOGNITA_API"]    ?? "develop"
    dependencies.append(contentsOf: [
            .package(url: "https://Kognita:dyjdov-bupgev-goffY8@github.com/MatsMoll/KognitaCore",       .branch(coreBranch)),
            .package(url: "https://Kognita:dyjdov-bupgev-goffY8@github.com/MatsMoll/KognitaPages",      .branch(pagesBranch)),
            .package(url: "https://Kognita:dyjdov-bupgev-goffY8@github.com/MatsMoll/kognita-rest-api",  .branch(apiBranch)),
        ]
    )
default:
    let coreVersion     = ProcessInfo.processInfo.environment["KOGNITA_CORE"]   ?? "2.0.0"
    let pagesVersion    = ProcessInfo.processInfo.environment["KOGNITA_PAGES"]  ?? "2.0.0"
    let apiVersion      = ProcessInfo.processInfo.environment["KOGNITA_API"]    ?? "2.0.0"
    dependencies.append(contentsOf: [
        .package(url: "https://Kognita:dyjdov-bupgev-goffY8@github.com/MatsMoll/KognitaCore",       from: Version(stringLiteral: coreVersion)),
        .package(url: "https://Kognita:dyjdov-bupgev-goffY8@github.com/MatsMoll/KognitaPages",      from: Version(stringLiteral: pagesVersion)),
        .package(url: "https://Kognita:dyjdov-bupgev-goffY8@github.com/MatsMoll/kognita-rest-api",  from: Version(stringLiteral: apiVersion)),
        ]
    )
}

let package = Package(
    name: "Kognita",
    platforms: [
        .macOS(.v10_15),
    ],
    dependencies: dependencies,
    targets: [
        .target(name: "App", dependencies: [
            "KognitaCore",
            "KognitaViews",
            "KognitaAPI",
            "Vapor",
            "URLEncodedForm",
            "HTMLKitVaporProvider",
        ]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App", "KognitaCoreTestable"])
    ]
)

