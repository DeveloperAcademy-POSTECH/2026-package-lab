//
//  SettingsRow.swift
//  LocalizationGuardExample
//
//  Created by sun on 9/12/26.
//

import SwiftUI

struct SettingsRow<Trailing: View>: View {
    let title: LocalizedStringKey
    let symbol: String
    let color: Color
    var verbatimTitle: String? = nil
    @ViewBuilder var trailing: () -> Trailing

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: symbol)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 29, height: 29)
                .background(color, in: RoundedRectangle(cornerRadius: 6))
                .accessibilityHidden(true)
            if let verbatimTitle {
                Text(verbatim: verbatimTitle)
            } else {
                Text(title)
            }
            Spacer(minLength: 8)
            trailing()
        }
        .padding(.vertical, 3)
    }
}

extension SettingsRow where Trailing == EmptyView {
    init(title: LocalizedStringKey, symbol: String, color: Color) {
        self.title = title
        self.symbol = symbol
        self.color = color
        self.trailing = { EmptyView() }
    }
}

extension SettingsRow where Trailing == EmptyView {
    init(verbatimTitle: String, symbol: String, color: Color) {
        self.title = ""
        self.verbatimTitle = verbatimTitle
        self.symbol = symbol
        self.color = color
        self.trailing = { EmptyView() }
    }
}
