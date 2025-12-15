//
//  RewardDetailPlaceholderView.swift
//  LotteryMachine
//
//  Created by Upgrade on 2025/12/15.
//

import SwiftData
import SwiftUI

struct RewardDetailPlaceholderView: View {
    let rewards: [Reward]
    let theme: SeasonalTheme
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            // Background for the detail view
            theme.background(for: colorScheme)
                .ignoresSafeArea()

            // Placeholder text when no reward is selected
            let message =
                rewards.isEmpty
                ? "請到設定裡增加尾牙獎項"
                : "請選擇一個獎項以查看詳細資訊"

            Text(message)
                .font(.largeTitle.bold())
                .foregroundColor(.primary)
        }
    }
}
