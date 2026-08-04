// swift-tools-version: 6.2
import PackageDescription

// 이 패키지는 기능 간 연쇄 의존성이 빌드 병렬성과 변경 범위에 미치는 영향을
// 관찰하기 위해 의도적으로 좋지 않은 직렬 그래프를 만듭니다.
let package = Package(
    name: "DependencyChainExperiment",
    platforms: [.iOS(.v26)],
    products: [
        .library(name: "ChainCamera", targets: ["ChainCamera"])
    ],
    targets: [
        .target(name: "ChainCore"),
        .target(name: "ChainVideoEdit", dependencies: ["ChainCore"]),
        .target(name: "ChainDetect", dependencies: ["ChainVideoEdit"]),
        .target(name: "ChainCamera", dependencies: ["ChainDetect"])
    ],
    swiftLanguageModes: [.v6]
)

