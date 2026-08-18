import Core

/// internal 타입이므로 FeatureCamera 외부에서는 가져오거나 생성할 수 없습니다.
struct CameraRepository {
    func makeCapture(number: Int) -> SharedModel {
        SharedModel(title: "Capture \(number)", detail: "Fake 48 MP photo")
    }
}
