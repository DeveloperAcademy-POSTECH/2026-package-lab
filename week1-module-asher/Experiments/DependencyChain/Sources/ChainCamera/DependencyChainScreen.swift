import ChainDetect
import SwiftUI

/// 앱이 가져오는 최상위 기능입니다. Camera → Detect → VideoEdit → Core 순으로 연결됩니다.
public struct DependencyChainScreen: View {
    @State private var frame = 0
    @State private var result = "아직 실행하지 않았습니다."
    private let detect = ChainDetectStage()

    public init() {}

    public var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "link")
                    .font(.system(size: 72))
                    .foregroundStyle(.red)

                Text("의도적인 직렬 의존성")
                    .font(.title2.bold())

                Text("Camera → Detect → VideoEdit → Core")
                    .font(.callout.monospaced())

                Button("가짜 파이프라인 실행") {
                    frame += 1
                    result = detect.detect(frame: frame)
                }
                .buttonStyle(.borderedProminent)

                Text(result)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .navigationTitle("Dependency Chain")
        }
    }
}

