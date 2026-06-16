// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "qr_code_scanner_plus",
    platforms: [
        .iOS(.v12),
    ],
    products: [
        .library(name: "qr-code-scanner-plus", targets: ["qr_code_scanner_plus"]),
    ],
    dependencies: [],
    targets: [
        // Main plugin target — uses pure AVFoundation (no CocoaPods-only MTBBarcodeScanner).
        .target(
            name: "qr_code_scanner_plus",
            dependencies: [],
            path: "Sources/qr_code_scanner_plus"
        ),
        .testTarget(
            name: "qr_code_scanner_plusTests",
            dependencies: ["qr_code_scanner_plus"],
            path: "Tests"
        ),
    ]
)
