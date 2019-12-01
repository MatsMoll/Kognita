// swift-tools-version:4.2
import PackageDescription

var dependencies: [Package.Dependency] = [
    // 💧 A server-side Swift web framework.
    .package(url: "https://github.com/vapor/vapor.git", from: "3.3.0"),

    // Encodes Form requests
    .package(url: "https://github.com/vapor/url-encoded-form.git", from: "1.0.0"),

    .package(url: "https://github.com/twof/VaporMailgunService.git", from: "1.5.0")
]


// Kognita Core

#if os(macOS) // Local development
dependencies.append(contentsOf: [
        .package(path: "../KognitaCore"),
        .package(path: "../KognitaViews"),
    ]
)
#else
dependencies.append(contentsOf: [
        .package(url: "https://Kognita:dyjdov-bupgev-goffY8@github.com/MatsMoll/KognitaCore", from: "1.0.0"),
        .package(url: "https://Kognita:dyjdov-bupgev-goffY8@github.com/MatsMoll/KognitaPages", from: "1.0.0")
    ]
)
#endif


let package = Package(
    name: "Kognita",
    dependencies: dependencies,
    targets: [
        .target(name: "App", dependencies: [
            "KognitaCore",
            "KognitaViews",
            "Vapor",
            "URLEncodedForm",
            "Mailgun"
        ]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App", "KognitaCoreTestable"])
    ]
)

