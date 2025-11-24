//
//  ContentView.swift
//  LotteryMachine
//
//  Created by Noah on 2025/11/21.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var rewards: [Reward]

    @State private var selectedReward: Reward?

    var body: some View {
        NavigationSplitView {
            VStack {
                List(selection: $selectedReward) {
                    Section(
                        header: HStack {
                            Text("Rewards")
                            Spacer()
                        }
                    ) {
                        ForEach(rewards) { reward in
                            HStack {
                                Text(reward.name)
                                Spacer()
                                if !reward.winners.isEmpty {
                                    ForEach(reward.winners) { winner in
                                        Text("\(winner.name)")
                                            .font(.headline)
                                            .foregroundColor(.green)
                                    }
                                }
                            }
                            .tag(reward)
                        }
                    }
                }
                .listStyle(SidebarListStyle())
            }
            .navigationTitle("Lottery Machine")
        } detail: {
            if let selectedReward {
                RewardDetailView(
                    reward: selectedReward
                )
            } else {
                if rewards.isEmpty {
                    Text("Go to Settings to add rewards and candidates.")
                        .font(.largeTitle)
                } else {
                    Text("Select a reward to see details")
                        .font(.largeTitle)
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Reward.self, Candidate.self], inMemory: true)
}
