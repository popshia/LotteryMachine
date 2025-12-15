//
//  CandidateManagementToolsView.swift
//  LotteryMachine
//
//  Created by Upgrade on 2025/12/15.
//

import SwiftData
import SwiftUI

struct CandidateManagementToolsView: View {
    @Bindable var reward: Reward
    let viewModel: CandidateDetailViewModel
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        HStack {
            Stepper(
                "總共抽取: \(reward.numberOfWinners)",
                value: $reward.numberOfWinners,
                in: 1...100
            )
            .onChange(of: reward.numberOfWinners) {
                // Save changes when number of winners changes
                try? modelContext.save()
            }
            .padding()

            Button("重置得獎人") {
                viewModel.resetWinners(from: reward, context: modelContext)
            }
            Button("匯入名單") {
                viewModel.importCandidatesFromCSV(to: reward, context: modelContext)
            }
            Button("清除名單") {
                viewModel.removeAllCandidates(from: reward, context: modelContext)
            }
        }
    }
}
