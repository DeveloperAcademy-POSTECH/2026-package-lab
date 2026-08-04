import SwiftUI

struct MonolithicDetectScreen: View {
    @State private var runCount = 0
    @State private var detections: [MonolithicSharedModel] = []
    private let service = MonolithicDetectService()

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button("Run Fake Detection") {
                        runCount += 1
                        detections = service.detect(run: runCount)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(MonolithicAppTheme.accent)
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
            .navigationTitle("Detect Folder")
        }
    }
}

