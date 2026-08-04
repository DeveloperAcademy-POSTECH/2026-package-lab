import Core
import SwiftUI

/// 다른 모듈에서 이 화면을 실행하므로 public 접근 수준이 필요합니다.
public struct DetectScreen: View {
    @State private var runCount = 0
    @State private var detections: [SharedModel] = []
    private let service = DetectService()

    public init() {}

    public var body: some View {
        NavigationStack {
            List {
                Section {
                    Button("Run Fake Detection") {
                        runCount += 1
                        detections = service.detect(run: runCount)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AppTheme.accent)
                }

                Section("Result") {
                    if detections.isEmpty {
                        ContentUnavailableView(
                            "No Detection Yet",
                            systemImage: "viewfinder",
                            description: Text("Run the fake model to produce sample output.")
                        )
                    } else {
                        ForEach(detections) { item in
                            LabeledContent(item.title, value: item.detail)
                        }
                    }
                }
            }
            .navigationTitle("Detect Module")
        }
    }
}
