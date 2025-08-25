// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "StudyGarden",
    platforms: [
        .iOS(.v17),
        .macOS(.v11)
    ],
    products: [
        .executable(name: "StudyGarden", targets: ["StudyGarden"])
    ],
    targets: [
        .executableTarget(
            name: "StudyGarden",
            path: "StudyGarden"
        )
    ]
)
