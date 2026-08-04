import Core

/// 모듈 경계 밖으로 노출되지 않는 내부 저장소 구현입니다.
struct DetectRepository {
    func sampleObjects(for run: Int) -> [SharedModel] {
        [
            SharedModel(title: "Skateboard", detail: "Confidence \(90 + run % 9)%"),
            SharedModel(title: "Person", detail: "Confidence \(85 + run % 10)%")
        ]
    }
}
