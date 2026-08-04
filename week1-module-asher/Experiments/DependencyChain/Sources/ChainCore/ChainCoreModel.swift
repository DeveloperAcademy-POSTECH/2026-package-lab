import Foundation

/// 직렬 의존성 실험의 가장 아래에 있는 공용 값 타입입니다.
public struct ChainCoreModel: Sendable {
    public let value: String

    public init(value: String) {
        self.value = value
    }
}

