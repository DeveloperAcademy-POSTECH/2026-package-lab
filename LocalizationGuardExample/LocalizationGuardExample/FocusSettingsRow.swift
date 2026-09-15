//
//  FocusSettingsRow.swift
//  LocalizationGuardExample
//
//  Created by sun on 9/12/26.
//

import SwiftUI

struct FocusSettingsRow: View {
    // Plain String returned from a function: not automatically extracted.
    private func title() -> String {
        return "집중 모드"
    }

    var body: some View {
        SettingsRow(verbatimTitle: title(), symbol: "moon.fill", color: .indigo)
    }
}
