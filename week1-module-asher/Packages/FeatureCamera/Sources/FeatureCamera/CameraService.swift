import Core

/// 내부 비즈니스 로직은 CameraScreen 뒤에 숨겨져 외부에 노출되지 않습니다.
struct CameraService {
    private let repository = CameraRepository()

    func capture(number: Int) -> SharedModel {
        Logger.log("Captured frame \(number)", category: "Camera")
        return repository.makeCapture(number: number)
    }
}
