//
//  CategoryHeaderView.swift
//  LotteryMachine
//
//  Created by Upgrade on 2025/12/15.
//

import SwiftUI

struct CategoryHeaderView: View {
    let category: String
    let theme: SeasonalTheme
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Text(category.isEmpty ? "Uncategorized" : category)
            .font(.title2.weight(.bold))
            .foregroundStyle(theme.darkRed(for: colorScheme))
            .padding(.vertical, 6)
            .padding(.horizontal, 10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(theme.red(for: colorScheme).opacity(0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(theme.gold.opacity(0.6), lineWidth: 1)
            )
            .padding(.vertical, 6)
    }
}
