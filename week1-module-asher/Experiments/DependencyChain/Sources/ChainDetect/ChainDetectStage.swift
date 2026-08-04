import ChainVideoEdit

/// 실험을 위해 Detect가 Video Edit 구현에 직접 의존하도록 만든 중간 단계입니다.
public struct ChainDetectStage {
    private let videoEdit = ChainVideoEditStage()

    public init() {}

    public func detect(frame: Int) -> String {
        "탐지 완료 · \(videoEdit.process(frame: frame).value)"
    }
}

