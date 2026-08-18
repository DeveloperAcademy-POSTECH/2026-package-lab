// swift-tools-version: 6.2
import PackageDescription

// Core는 모듈형 빌드 그래프의 루트 라이브러리 타깃입니다.
// 모든 기능이 Core에 의존하지만, Core는 어떤 기능에도 의존하지 않습니다.
let package = Package(
    name: "Core",
    platforms: [.iOS(.v26)],
    products: [
        .library(name: "Core", targets: ["Core"])
    ],
    targets: [
        .target(name: "Core")
    ],
    swiftLanguageModes: [.v6]
)
