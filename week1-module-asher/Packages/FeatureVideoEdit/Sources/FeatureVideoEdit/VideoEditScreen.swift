import Core
import SwiftUI

public struct VideoEditScreen: View {
    @State private var duration = 12.0
    @State private var result: SharedModel?
    private let service = VideoEditService()

    public init() {}

    public var body: some View {
        NavigationStack {
            Form {
                Section("Fake timeline") {
                    Slider(value: $duration, in: 3...30, step: 1)
                        .tint(AppTheme.accent)
                    LabeledContent("Clip duration", value: "\(Int(duration)) seconds")
                }

                Button("Export Preview") {
                    result = service.export(duration: Int(duration))
                }

                if let result {
                    Section("Latest export") {
                        LabeledContent(result.title, value: result.detail)
                    }
                }
            }
            .navigationTitle("Video Edit Module")
        }
    }
}
