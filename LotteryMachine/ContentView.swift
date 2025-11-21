//
//  ContentView.swift
//  LotteryMachine
//
//  Created by Noah on 2025/11/21.
//

import SwiftUI

struct ContentView: View {
    @State private var rewards = [
        Reward(
            name: "First Prize",
            candidates: [
                Candidate(name: "Alice"), Candidate(name: "Bob"),
                Candidate(name: "Charlie"),
            ]
        ),
        Reward(
            name: "Second Prize",
            candidates: [Candidate(name: "Dave"), Candidate(name: "Eve")]
        ),
        Reward(
            name: "Third Prize",
            candidates: [Candidate(name: "Frank")]
        ),
    ]

    @State private var newRewardName = ""
    @State private var newCandidateName = ""
    @State private var selectedReward: Reward?

    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(rewards) { reward in
                        NavigationLink(
                            destination: RewardDetailView(
                                reward: $rewards[getIndex(for: reward)],
                                newCandidateName: $newCandidateName
                            )
                        ) {
                            HStack {
                                Text(reward.name)
                                Spacer()
                                if !reward.winners.isEmpty {
                                    Text("Winners: \(reward.winners.count)")
                                        .font(.headline)
                                        .foregroundColor(.green)
                                }
                            }
                        }
                    }
                }
                .listStyle(SidebarListStyle())

                HStack {
                    TextField("New Reward", text: $newRewardName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onSubmit { addReward() }
                }
                .padding()
            }
            .navigationTitle("Lottery Machine")

            Text("Select a reward to see details")
                .font(.largeTitle)
        }
    }

    private func addReward() {
        if !newRewardName.isEmpty {
            rewards.append(Reward(name: newRewardName, candidates: []))
            newRewardName = ""
        }
    }

    private func getIndex(for reward: Reward) -> Int {
        if let index = rewards.firstIndex(where: { $0.id == reward.id }) {
            return index
        }
        return 0
    }
}

#Preview {
    ContentView()
}
