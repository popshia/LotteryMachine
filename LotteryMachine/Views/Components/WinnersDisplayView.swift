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
        VStack(spacing: 10) {
            Text("🎉 中獎者 🎉")
                .padding(.horizontal, 8)
            ViewThatFits(in: .horizontal) {
                HStack(spacing: 40) {
                    winnersList
                }
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))], spacing: 20) {
                    winnersList
                }
            }
            .padding(.horizontal, 12)
        }
        .padding(.vertical, 12)
        .breathingContainer(
            backgroundColor: .red, borderColor: theme.gold, cornerRadius: 12
        )
        .padding()
        .font(.system(size: 48))
        .fontWeight(.bold)
        .foregroundColor(.black)
        .transition(.scale)
    }

    @ViewBuilder
    private var winnersList: some View {
        ForEach(
            reward.winners.sorted {
                ($0.winTimestamp ?? Date.distantPast)
                    < ($1.winTimestamp ?? Date.distantPast)
            }
        ) { winner in
            if winner.name.count > 3 {
                (Text(winner.name.prefix(3)).font(.system(size: 48))
                    + Text(String(winner.name.last!)).font(.system(size: 24)).baselineOffset(
                        24
                    ))
                    .multilineTextAlignment(.center)
            } else {
                Text(winner.name).font(.system(size: 48))
                    .multilineTextAlignment(.center)
            }
        }
    }
}
