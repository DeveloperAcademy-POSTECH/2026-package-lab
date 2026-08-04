import SwiftUI

struct MonolithicSettingsScreen: View {
    @State private var analyticsEnabled = false
    @State private var status: String?

    var body: some View {
        NavigationStack {
            Form {
                Toggle("Share fake analytics", isOn: $analyticsEnabled)

                Button("Save Settings") {
                    MonolithicLogger.log("Saved fake settings", category: "Settings")
                    status = analyticsEnabled
                        ? "Fake analytics enabled"
                        : "Fake analytics disabled"
                }

                if let status {
                    Section("Status") {
                        LabeledContent("Analytics", value: status)
                    }
                }
            }
            .tint(MonolithicAppTheme.accent)
            .navigationTitle("Settings Folder")
        }
    }
}

