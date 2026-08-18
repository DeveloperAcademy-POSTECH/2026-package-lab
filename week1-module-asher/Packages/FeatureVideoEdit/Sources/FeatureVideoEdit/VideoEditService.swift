import Core

/// 내부 Service이며, 이 패키지는 VideoEditScreen만 외부에 공개합니다.
struct VideoEditService {
    private let repository = VideoEditRepository()

    func export(duration: Int) -> SharedModel {
        Logger.log("Exported fake \(duration)s clip", category: "VideoEdit")
        return repository.exportSummary(duration: duration)
    }
}
