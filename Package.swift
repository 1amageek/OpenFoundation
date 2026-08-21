// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "OpenFoundation",
    defaultLocalization: "en",
    products: [
        .library(
            name: "OpenFoundation",
            targets: ["OpenFoundation"]
        ),
        .library(
            name: "OpenFoundationEmbeddedMath",
            targets: ["COpenFoundationEmbeddedMath"]
        ),
        .library(
            name: "OpenFoundationEmbeddedFileSystem",
            targets: ["COpenFoundationEmbeddedFileSystem"]
        )
    ],
    targets: [
        .target(
            name: "COpenFoundationEmbeddedMath",
            publicHeadersPath: "include"
        ),
        .target(
            name: "COpenFoundationEmbeddedFileSystem",
            publicHeadersPath: "include"
        ),
        .target(
            name: "OpenFoundation",
            swiftSettings: [
                .enableExperimentalFeature("Extern")
            ]
        ),
        .target(
            name: "OpenFoundationToolchainIdentity",
            path: "Tests/Support/OpenFoundationToolchainIdentity"
        ),
        .executableTarget(
            name: "OpenFoundationGeometrySmoke",
            dependencies: ["OpenFoundation"],
            path: "Tests/Runtime/OpenFoundationGeometrySmoke"
        ),
        .executableTarget(
            name: "OpenFoundationLocalizationSmoke",
            dependencies: ["OpenFoundation"],
            path: "Tests/Runtime/OpenFoundationLocalizationSmoke",
            resources: [.process("Resources")]
        ),
        .executableTarget(
            name: "OpenFoundationEmbeddedMathSmoke",
            dependencies: [
                "OpenFoundation",
                "COpenFoundationEmbeddedMath"
            ],
            path: "Tests/Runtime/OpenFoundationEmbeddedMathSmoke"
        ),
        .executableTarget(
            name: "OpenFoundationEmbeddedFileSystemSmoke",
            dependencies: [
                "OpenFoundation",
                "COpenFoundationEmbeddedFileSystem"
            ],
            path: "Tests/Runtime/OpenFoundationEmbeddedFileSystemSmoke",
            linkerSettings: [
                .linkedLibrary(
                    "swiftUnicodeDataTables",
                    .when(platforms: [.wasi])
                )
            ]
        ),
        .testTarget(
            name: "OpenFoundationTests",
            dependencies: [
                "OpenFoundation",
                "OpenFoundationToolchainIdentity"
            ]
        )
    ],
    swiftLanguageModes: [.v6]
)
