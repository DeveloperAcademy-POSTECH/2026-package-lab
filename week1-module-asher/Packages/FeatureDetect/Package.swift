// swift-tools-version: 6.2
import PackageDescription

// FeatureDetect는 ModularApp과 기능 전용 Example App에서 각각 빌드할 수 있습니다.
let package = Package(
    name: "FeatureDetect",
    platforms: [.iOS(.v26)],
    products: [.library(name: "FeatureDetect", targets: ["FeatureDetect"])],
    dependencies: [.package(path: "../Core")],
    targets: [
        .target(
            name: "FeatureDetect",
            dependencies: [.product(name: "Core", package: "Core")]
        )
    ],
    swiftLanguageModes: [.v6]
)
