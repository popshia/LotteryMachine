//
//  CandidateListView.swift
//  LotteryMachine
//
//  Created by Upgrade on 2025/12/15.
//

import SwiftData
import SwiftUI

struct CandidateListView: View {
    let reward: Reward
    let viewModel: CandidateDetailViewModel
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        List {
            ForEach(reward.candidates) { candidate in
                Text(candidate.name)
                    .foregroundColor(reward.winners.contains(candidate) ? .green : .primary)
                    .contextMenu {
                        Button("編輯") {
                            viewModel.prepareEdit(for: candidate)
                        }
                        Button("刪除", role: .destructive) {
                            viewModel.deleteCandidate(
                                candidate, from: reward, context: modelContext)
                        }
                    }
            }
        }
    }
}
