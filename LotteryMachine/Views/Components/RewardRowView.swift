//
//  RewardRowView.swift
//  LotteryMachine
//
//  Created by Upgrade on 2025/12/15.
//

import SwiftData
import SwiftUI

struct RewardRowView: View {
    let reward: Reward
    let theme: SeasonalTheme

    var body: some View {
        HStack {
            Image(systemName: "sparkles")
                .foregroundStyle(theme.gold)
            Text(reward.name)
                .font(.title.weight(.semibold))
            Image(systemName: "sparkles")
                .foregroundStyle(theme.gold)
        }
    }
}
