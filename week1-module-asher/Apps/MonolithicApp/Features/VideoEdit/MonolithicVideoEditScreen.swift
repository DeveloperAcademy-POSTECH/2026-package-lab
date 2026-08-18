import SwiftUI

struct MonolithicVideoEditScreen: View {
    @State private var duration = 12.0
    @State private var exportMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("Fake timeline") {
                    Slider(value: $duration, in: 3...30, step: 1)
                        .tint(MonolithicAppTheme.accent)
                    LabeledContent("Clip duration", value: "\(Int(duration)) seconds")
                }

                Button("Export Preview") {
                    let seconds = Int(duration)
                    MonolithicLogger.log("Exported fake \(seconds)s clip", category: "VideoEdit")
                    exportMessage = "Preview exported · \(seconds)-second clip"
                }

                if let exportMessage {
                    Section("Latest export") {
                        Text(exportMessage)
                    }
                }
            }
            .navigationTitle("Video Edit Folder")
        }
    }
}

