import Core
import FeatureDetect
import SwiftUI

// 이 기능 전용 앱 타깃은 의도적으로 Core와 FeatureDetect만 연결합니다.
// 짧은 빌드 그래프 덕분에 Detect UI를 개발할 때 피드백을 빠르게 받을 수 있습니다.
@main
struct FeatureDetectExampleApp: App {
    var body: some Scene {
        WindowGroup {
            DetectScreen()
                .tint(AppTheme.accent)
        }
    }
}
