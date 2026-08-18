import Core
import SwiftUI

/// 앱이 이 모듈에서 사용해야 하는 유일한 UI 진입점입니다.
public struct CameraScreen: View {
    @State private var captures: [SharedModel] = []
    private let service = CameraService()

    public init() {}

    public var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "camera.viewfinder")
                    .font(.system(size: 76))
                    .foregroundStyle(AppTheme.accent)

                Text("Frames captured: \(captures.count)")
                    .font(.title2.bold())

                Button("Take Fake Photo") {
                    captures.append(service.capture(number: captures.count + 1))
                }
                .buttonStyle(.borderedProminent)
                .tint(AppTheme.accent)

                if let latest = captures.last {
                    Text("\(latest.title) · \(latest.detail)")
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppTheme.background)
            .navigationTitle("Camera Module")
        }
    }
}
