// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "TheInitiative",
    platforms: [
        .macOS(.v10_14),
    ],
    products: [
        .executable(name: "init", targets: ["TheInitiative"]),
    ],
    dependencies: [
        // .package(url: "https://github.com/colinta/Ashen.git", .branch("main")),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.3.0"),
        .package(path: "../Ashen"),
        .package(
          url: "https://github.com/firebase/firebase-ios-sdk.git",
          from: "8.0.0"
        ),
    ],
    targets: [
        .target(name: "TheInitiative", dependencies: [
            "Ashen",
            "ArgumentParser",
            "FirebaseAuth",
            "FirebaseDatabase"
        ]),
    ]
)
