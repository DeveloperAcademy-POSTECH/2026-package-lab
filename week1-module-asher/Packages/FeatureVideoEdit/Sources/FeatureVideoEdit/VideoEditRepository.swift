import Core

/// 가짜 편집 결과를 만드는 내부 Repository입니다.
struct VideoEditRepository {
    func exportSummary(duration: Int) -> SharedModel {
        SharedModel(title: "Preview exported", detail: "\(duration)-second clip")
    }
}
