import Core

/// 의도적으로 디스크에 아무것도 기록하지 않는 가짜 내부 저장 계층입니다.
struct SettingsRepository {
    func statusMessage(isAnalyticsEnabled: Bool) -> SharedModel {
        SharedModel(
            title: "Analytics",
            detail: isAnalyticsEnabled ? "Fake analytics enabled" : "Fake analytics disabled"
        )
    }
}
