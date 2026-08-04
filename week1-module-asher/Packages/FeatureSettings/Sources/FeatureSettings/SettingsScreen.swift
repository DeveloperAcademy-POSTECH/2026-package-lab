import Core
import SwiftUI

public struct SettingsScreen: View {
    @State private var analyticsEnabled = false
    @State private var status: SharedModel?
    private let service = SettingsService()

    public init() {}

    public var body: some View {
        NavigationStack {
            Form {
                Toggle("Share fake analytics", isOn: $analyticsEnabled)

                Button("Save Settings") {
                    status = service.save(isAnalyticsEnabled: analyticsEnabled)
                }

                if let status {
                    Section("Status") {
                        LabeledContent(status.title, value: status.detail)
                    }
                }
            }
            .tint(AppTheme.accent)
            .navigationTitle("Settings Module")
        }
    }
}
