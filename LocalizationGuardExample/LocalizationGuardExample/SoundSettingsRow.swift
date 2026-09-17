//
//  SoundSettingsRow.swift
//  LocalizationGuardExample
//
//  Created by sun on 9/12/26.
//

import SwiftUI

struct SoundSettingsRow: View {
    // Plain String: not automatically extracted into the String Catalog.
    private let title: String = "사운드 및 햅틱"

    var body: some View {
        SettingsRow(verbatimTitle: title, symbol: "speaker.wave.3.fill", color: .pink)
    }
}
