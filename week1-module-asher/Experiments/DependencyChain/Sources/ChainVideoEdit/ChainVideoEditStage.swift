import ChainCore

/// 직렬 그래프의 최하위 기능입니다. 이 공개 API 변경은 모든 상위 기능에 전파될 수 있습니다.
public struct ChainVideoEditStage {
    public init() {}

    public func process(frame: Int) -> ChainCoreModel {
        ChainCoreModel(value: "편집된 프레임 #\(frame)")
    }
}
