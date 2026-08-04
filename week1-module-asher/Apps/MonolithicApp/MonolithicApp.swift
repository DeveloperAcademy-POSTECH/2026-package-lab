import SwiftUI

// 이 @main은 하나의 앱 타깃에 속합니다. Apps/MonolithicApp 아래의 모든 파일은
// 동일한 MonolithicApp 모듈로 컴파일됩니다.
@main
struct MonolithicApp: App {
    var body: some Scene {
        WindowGroup {
            MonolithicRootView()
        }
    }
}
