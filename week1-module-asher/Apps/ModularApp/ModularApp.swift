import SwiftUI

// 이 얇은 앱 타깃은 패키지 타깃 5개의 공개 API를 조합합니다.
@main
struct ModularApp: App {
    var body: some Scene {
        WindowGroup {
            ModularRootView()
        }
    }
}
