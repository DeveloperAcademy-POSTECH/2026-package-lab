//
//  NotificationSettingsRow.swift
//  LocalizationGuardExample
//
//  Created by sun on 9/12/26.
//

import SwiftUI

struct NotificationSettingsRow: View {
    // Intentionally absent from the String Catalog for the demo.
    private let title: LocalizedStringKey = "알림"

    private let previewCount = 3

    private var previewText: String {
        "미리보기 \(previewCount)개"
    }

    var body: some View {
        SettingsRow(title: title, symbol: "bell.badge.fill", color: .red) {
            Text(verbatim: previewText).foregroundStyle(.secondary)
        }
    }
}
