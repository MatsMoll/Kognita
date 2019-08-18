// swift-tools-version:4.2
import PackageDescription

var dependencies: [Package.Dependency] = [
    // 💧 A server-side Swift web framework.
    .package(url: "https://github.com/vapor/vapor.git", from: "3.2.2"),

    // Encodes Form requests
    .package(url: "https://github.com/vapor/url-encoded-form.git", from: "1.0.0")
]


// Kognita Core

#if os(macOS) // Local development
dependencies.append(contentsOf: [
        .package(path: "../KognitaCore"),
        .package(path: "../KognitaViews")
    ]
)
#else
dependencies.append(
    .package(url: "https://MatsKognita:dyjdov-bupgev-goffY8@bitbucket.org/MatsEikelandMollestad/kognita-core.git", .branch("master"))
)
#endif


let package = Package(
    name: "KognitaVapor",
    dependencies: dependencies,
    targets: [
        .target(name: "App", dependencies: ["KognitaCore", "KognitaViews", "Vapor", "URLEncodedForm"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)

