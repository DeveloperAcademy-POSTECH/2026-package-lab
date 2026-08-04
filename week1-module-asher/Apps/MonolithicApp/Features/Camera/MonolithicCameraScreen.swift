import SwiftUI

struct MonolithicCameraScreen: View {
    @State private var captures: [MonolithicSharedModel] = []

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "camera.viewfinder")
                    .font(.system(size: 76))
                    .foregroundStyle(MonolithicAppTheme.accent)

                Text("Frames captured: \(captures.count)")
                    .font(.title2.bold())

                Button("Take Fake Photo") {
                    let number = captures.count + 1
                    MonolithicLogger.log("Captured frame \(number)", category: "Camera")
                    captures.append(
                        MonolithicSharedModel(
                            title: "Capture \(number)",
                            detail: "Fake 48 MP photo"
                        )
                    )
                }
                .buttonStyle(.borderedProminent)
                .tint(MonolithicAppTheme.accent)

                if let latest = captures.last {
                    Text("\(latest.title) · \(latest.detail)")
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(MonolithicAppTheme.background)
            .navigationTitle("Camera Folder")
        }
    }
}

