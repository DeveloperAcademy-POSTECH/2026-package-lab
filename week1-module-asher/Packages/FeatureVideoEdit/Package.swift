// swift-tools-version: 6.2
import PackageDescription

// FeatureVideoEdit는 다른 기능과 형제 관계이므로 서로 병렬로 컴파일할 수 있습니다.
let package = Package(
    name: "FeatureVideoEdit",
    platforms: [.iOS(.v26)],
    products: [.library(name: "FeatureVideoEdit", targets: ["FeatureVideoEdit"])],
    dependencies: [.package(path: "../Core")],
    targets: [
        .target(
            name: "FeatureVideoEdit",
            dependencies: [.product(name: "Core", package: "Core")]
        )
    ],
    swiftLanguageModes: [.v6]
)
