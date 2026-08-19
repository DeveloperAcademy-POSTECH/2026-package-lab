// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "ShoppingExample",
    products: [
        .library(name: "ShoppingModels", targets: ["ShoppingModels"]),
        .library(name: "ShoppingCart", targets: ["ShoppingCart"]),
        .library(name: "ShoppingCheckout", targets: ["ShoppingCheckout"]),
        .executable(name: "ShoppingApp", targets: ["ShoppingApp"])
    ],
    targets: [
        .target(name: "ShoppingModels"),
        .target(
            name: "ShoppingCart",
            dependencies: ["ShoppingModels"]
        ),
        .target(
            name: "ShoppingCheckout",
            dependencies: ["ShoppingCart"]
        ),
        .executableTarget(
            name: "ShoppingApp",
            dependencies: [
                "ShoppingModels",
                "ShoppingCart",
                "ShoppingCheckout"
            ]
        ),
        .testTarget(
            name: "ShoppingCartTests",
            dependencies: ["ShoppingCart"]
        ),
        .testTarget(
            name: "ShoppingCheckoutTests",
            dependencies: ["ShoppingCheckout"]
        )
    ]
)
