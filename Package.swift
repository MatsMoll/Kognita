// swift-tools-version:5.1
import PackageDescription

var dependencies: [Package.Dependency] = [
    // 💧 A server-side Swift web framework.
    .package(url: "https://github.com/vapor/vapor.git", from: "3.3.1"),

    // Encodes Form requests
    .package(url: "https://github.com/vapor/url-encoded-form.git", from: "1.0.0"),

    .package(url: "https://github.com/MatsMoll/htmlkit-vapor-3-provider.git", from: "1.0.0-beta.3"),
]


// Kognita Core

#if os(macOS) // Local development
dependencies.append(contentsOf: [
        .package(path: "../KognitaAPI"),
        .package(path: "../KognitaCore"),
        .package(path: "../KognitaViews"),
    ]
)
#else
dependencies.append(contentsOf: [
        .package(url: "https://Kognita:dyjdov-bupgev-goffY8@github.com/MatsMoll/KognitaCore", .branch("develop")),
        .package(url: "https://Kognita:dyjdov-bupgev-goffY8@github.com/MatsMoll/KognitaPages", .branch("develop")),
        .package(url: "https://Kognita:dyjdov-bupgev-goffY8@github.com/MatsMoll/kognita-rest-api", .branch("develop")),
    ]
)
#endif


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

