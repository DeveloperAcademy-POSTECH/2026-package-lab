// swift-tools-version: 6.2
import PackageDescription

// FeatureSettings도 리프 타깃이며, 기능 패키지끼리는 서로 의존하지 않습니다.
let package = Package(
    name: "FeatureSettings",
    platforms: [.iOS(.v26)],
    products: [.library(name: "FeatureSettings", targets: ["FeatureSettings"])],
    dependencies: [.package(path: "../Core")],
    targets: [
        .target(
            name: "FeatureSettings",
            dependencies: [.product(name: "Core", package: "Core")]
        )
    ],
    swiftLanguageModes: [.v6]
)
