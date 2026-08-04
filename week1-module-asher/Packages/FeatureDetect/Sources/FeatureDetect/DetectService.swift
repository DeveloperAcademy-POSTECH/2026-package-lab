import Core

/// 증분 빌드를 실습할 때 수정할 내부 구현 파일입니다.
struct DetectService {
    private let repository = DetectRepository()

    func detect(run: Int) -> [SharedModel] {
        Logger.log("Ran fake model inference \(run)", category: "Detect")
        return repository.sampleObjects(for: run)
    }
}
