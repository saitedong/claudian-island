// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ClaudianIsland",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "ClaudianIsland",
            path: "Sources/ClaudianIsland",
            resources: [.copy("../../Resources/Info.plist")]
        )
    ]
)
