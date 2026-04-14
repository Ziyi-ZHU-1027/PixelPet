// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PixelPet",
    platforms: [.macOS(.v13)],
    dependencies: [
        .package(
            url: "https://github.com/sparkle-project/Sparkle",
            from: "2.0.0"
        ),
    ],
    targets: [
        .target(
            name: "PixelPetKit",
            path: "Sources/PixelPetKit"
        ),
        .executableTarget(
            name: "PixelPetApp",
            dependencies: [
                "PixelPetKit",
                .product(name: "Sparkle", package: "Sparkle"),
            ],
            path: "Sources/PixelPetApp"
        ),
        .testTarget(
            name: "PixelPetKitTests",
            dependencies: ["PixelPetKit"],
            path: "Tests/PixelPetKitTests"
        ),
    ]
)
