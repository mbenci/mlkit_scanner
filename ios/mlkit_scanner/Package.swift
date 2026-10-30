// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "mlkit_scanner",
    platforms: [
        .iOS("15.0")
    ],
    products: [
        .library(name: "mlkit-scanner", targets: ["mlkit_scanner"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "mlkit_scanner",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ],
            resources: [
                .process("Resources")
            ]
        )
    ]
)
