// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PixelPet",
    platforms: [.macOS(.v13)],
    targets: [
        .target(
            name: "PixelPetKit",
            path: "Sources/PixelPetKit"
        ),
        .executableTarget(
            name: "PixelPetApp",
            dependencies: ["PixelPetKit"],
            path: "Sources/PixelPetApp"
        ),
        .testTarget(
            name: "PixelPetKitTests",
            dependencies: ["PixelPetKit"],
            path: "Tests/PixelPetKitTests"
        ),
    ]
)
