//
//  SettingsRewardRowView.swift
//  LotteryMachine
//
//  Created by Upgrade on 2025/12/15.
//

import SwiftData
import SwiftUI

struct SettingsRewardRowView: View {
    let reward: Reward
    let viewModel: SettingsViewModel
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationLink(
            destination: CandidateDetailView(reward: reward)
        ) {
            Text(reward.name).font(.title2)
        }
        .contextMenu {
            Button("編輯") {
                viewModel.prepareEdit(for: reward)
            }
            Button("刪除", role: .destructive) {
                viewModel.deleteReward(reward, context: modelContext)
            }
        }
    }
}
