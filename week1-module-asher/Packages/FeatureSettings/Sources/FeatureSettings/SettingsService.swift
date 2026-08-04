import Core

/// 앱 타깃에서 접근할 수 없도록 숨긴 내부 비즈니스 로직입니다.
struct SettingsService {
    private let repository = SettingsRepository()

    func save(isAnalyticsEnabled: Bool) -> SharedModel {
        Logger.log("Saved fake settings", category: "Settings")
        return repository.statusMessage(isAnalyticsEnabled: isAnalyticsEnabled)
    }
}
