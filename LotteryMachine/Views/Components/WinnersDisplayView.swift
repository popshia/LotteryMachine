//
//  WinnersDisplayView.swift
//  LotteryMachine
//
//  Created by Upgrade on 2025/12/15.
//

import SwiftData
import SwiftUI

struct WinnersDisplayView: View {
    let reward: Reward
    let theme: SeasonalTheme

    var body: some View {
        VStack {
            Text("🎉 中獎者 🎉")
            Text(
                reward.winners
                    .map(\.name)
                    .joined(separator: "    ")
            )
            .fontWeight(.bold)
            .foregroundColor(.black)
        }
        .padding()
        .breathingContainer(
            backgroundColor: .red, borderColor: theme.gold, cornerRadius: 12
        )
        .padding()
        .font(.system(size: 60))
        .transition(.scale)
    }
}
