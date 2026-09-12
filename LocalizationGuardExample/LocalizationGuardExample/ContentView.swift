//
//  ContentView.swift
//  LocalizationGuardExample
//
//  Created by sun on 9/11/26.
//

import SwiftUI

struct ContentView: View {
    @State private var isAirplaneModeOn = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: 14) {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 56))
                            .foregroundStyle(.gray)
                            .accessibilityHidden(true)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(verbatim: "sun") // localization-guard:disable-line
                                .font(.title2.weight(.semibold))
                            Text("Apple 계정, iCloud 및 기타")
                                .font(.footnote)
                        }
                    }
                    .padding(.vertical, 8)
                }

                Section {
                    SettingsRow(title: "에어플레인 모드", symbol: "airplane", color: .orange) {
                        Toggle("에어플레인 모드", isOn: $isAirplaneModeOn)
                            .labelsHidden()
                            .fixedSize()
                    }
                    SettingsRow(title: "Wi-Fi", symbol: "wifi", color: .blue) {
                        Text("연결 안 됨").foregroundStyle(.secondary)
                    }
                    SettingsRow(title: "Bluetooth", symbol: "antenna.radiowaves.left.and.right", color: .blue) {
                        Text("켬").foregroundStyle(.secondary)
                    }
                }

                Section {
                    NotificationSettingsRow()
                    SoundSettingsRow()
                    FocusSettingsRow()
                }

                Section {
                    SettingsRow(verbatimTitle: String(localized: "settings.general", defaultValue: "일반"), symbol: "gear", color: .gray)
                    SettingsRow(title: "디스플레이 및 밝기", symbol: "textformat.size", color: .blue)
                    SettingsRow(title: "개인정보 보호 및 보안", symbol: "hand.raised.fill", color: .blue)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("설정")
        }
    }
}

