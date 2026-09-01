// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "ObjectiveCSupportDemo",

    products: [
        .library(
            name: "GreetingSwift",
            targets: ["GreetingSwift"]
        ),
        .executable(
            name: "Demo",
            targets: ["Demo"]
        )
    ],

    targets: [
        .target(
            name: "GreetingObjC"
        ),

        .target(
            name: "GreetingSwift",
            dependencies: ["GreetingObjC"]
        ),

        .executableTarget(
            name: "Demo",
            dependencies: ["GreetingSwift"]
        )
    ]
)