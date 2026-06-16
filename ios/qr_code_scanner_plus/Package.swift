// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "qr_code_scanner_plus",
    platforms: [
        .iOS(.v12),
    ],
    products: [
        // Product name uses hyphens when the package name contains underscores (Flutter convention).
        .library(name: "qr-code-scanner-plus", targets: ["qr_code_scanner_plus"]),
    ],
    dependencies: [
        // Flutter injects this local package at build time when SPM is enabled.
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
    ],
    targets: [
        .target(
            name: "qr_code_scanner_plus",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
            ],
            path: "Sources/qr_code_scanner_plus"
        ),
        .testTarget(
            name: "qr_code_scanner_plusTests",
            dependencies: ["qr_code_scanner_plus"],
            path: "Tests"
        ),
    ]
)
