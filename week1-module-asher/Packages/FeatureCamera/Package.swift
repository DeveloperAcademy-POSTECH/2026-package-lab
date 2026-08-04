// swift-tools-version: 6.2
import PackageDescription

// FeatureCamera는 Core에만 의존하는 독립적인 빌드 타깃입니다.
let package = Package(
    name: "FeatureCamera",
    platforms: [.iOS(.v26)],
    products: [.library(name: "FeatureCamera", targets: ["FeatureCamera"])],
    dependencies: [.package(path: "../Core")],
    targets: [
        .target(
            name: "FeatureCamera",
            dependencies: [.product(name: "Core", package: "Core")]
        )
    ],
    swiftLanguageModes: [.v6]
)
