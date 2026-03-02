// swift-tools-version:6.1
import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "AppLoggerMacro",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "AppLogger", targets: ["AppLogger"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax.git", "600.0.0"..<"603.0.0"),
    ],
    targets: [
        .macro(
            name: "AppLoggerMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ]
        ),
        .target(
            name: "AppLogger",
            dependencies: ["AppLoggerMacros"]
        ),
        .testTarget(
            name: "AppLoggerTests",
            dependencies: [
                "AppLoggerMacros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ]
        ),
    ]
)
