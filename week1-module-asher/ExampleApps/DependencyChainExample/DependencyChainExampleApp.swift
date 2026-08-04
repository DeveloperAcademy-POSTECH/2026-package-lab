import ChainCamera
import SwiftUI

// 연구 문서의 ‘구조 A’를 실행하기 위한 실험용 앱입니다.
// 실제 앱에서는 기능 간 이런 연쇄 의존성을 피하는 것이 목적입니다.
@main
struct DependencyChainExampleApp: App {
    var body: some Scene {
        WindowGroup {
            DependencyChainScreen()
        }
    }
}

