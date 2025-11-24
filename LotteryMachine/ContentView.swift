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

    @State private var newRewardName = ""
    @State private var newCandidateName = ""
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

                HStack {
                    TextField("New Reward", text: $newRewardName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onSubmit { addReward() }
                }
                .padding()
            }
            .navigationTitle("Lottery Machine")
            .onAppear {
                if rewards.isEmpty {
                    insertSampleData()
                }
            }
        } detail: {
            if let selectedReward {
                RewardDetailView(
                    reward: selectedReward,
                    newCandidateName: $newCandidateName
                )
            } else {
                Text("Select a reward to see details")
                    .font(.largeTitle)
            }
        }
    }

    private func addReward() {
        if !newRewardName.isEmpty {
            let newReward = Reward(name: newRewardName, candidates: [])
            modelContext.insert(newReward)
            newRewardName = ""
        }
    }
    
    private func insertSampleData() {
        modelContext.insert(Reward(
            name: "MacBook Pro 14\"",
            candidates: [
                Candidate(name: "Alice"), Candidate(name: "Tai"),
                Candidate(name: "Jordan"),
            ]
        ))
        modelContext.insert(Reward(
            name: "Switch 2",
            candidates: [Candidate(name: "YcKao"), Candidate(name: "Marty")]
        ))
        modelContext.insert(Reward(
            name: "Playstation 5",
            candidates: [
                Candidate(name: "Serena"), Candidate(name: "Kevin"),
                Candidate(name: "Tony"), Candidate(name: "Nemo"),
            ]
        ))
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Reward.self, Candidate.self], inMemory: true)
}
