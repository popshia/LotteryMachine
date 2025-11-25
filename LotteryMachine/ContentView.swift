//
//  ContentView.swift
//  LotteryMachine
//
//  Created by Noah on 2025/11/21.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [
        SortDescriptor(\Reward.category), SortDescriptor(\Reward.name),
    ])
    private var rewards: [Reward]

    @State private var selectedReward: Reward?

    private var groupedRewards: [String: [Reward]] {
        Dictionary(grouping: rewards, by: { $0.category })
    }

    private var sortedCategories: [String] {
        groupedRewards.keys.sorted()
    }

    var body: some View {
        NavigationSplitView {
            VStack {
                List(selection: $selectedReward) {
                    ForEach(sortedCategories, id: \.self) { category in
                        Section(
                            header: Text(
                                category.isEmpty ? "Uncategorized" : category
                            ).font(.title2)
                        ) {
                            ForEach(groupedRewards[category] ?? []) { reward in
                                HStack {
                                    Text(reward.name).foregroundStyle(
                                        !reward.winners.isEmpty ? .green : .primary
                                    )
                                    .font(.title)
                                }
                                .tag(reward)
                            }
                        }
                    }
                }
                .listStyle(SidebarListStyle())
            }
            .navigationTitle("Lottery Machine")
        } detail: {
            //        } content: {
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
        //        } detail: {
        //        }
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: Reward.self,
            Candidate.self,
            configurations: config
        )

        let reward1 = Reward(
            name: "Christmas Bonus",
            category: "Holiday",
            numberOfWinners: 2
        )
        reward1.candidates.append(Candidate(name: "Noah"))
        reward1.candidates.append(Candidate(name: "Liam"))
        reward1.candidates.append(Candidate(name: "Emma"))

        let reward2 = Reward(
            name: "Holiday Raffle",
            category: "Holiday",
            numberOfWinners: 1
        )
        reward2.candidates.append(Candidate(name: "Olivia"))
        reward2.candidates.append(Candidate(name: "William"))

        let reward3 = Reward(
            name: "Q1 Bonus",
            category: "Quarterly",
            numberOfWinners: 1
        )

        container.mainContext.insert(reward1)
        container.mainContext.insert(reward2)
        container.mainContext.insert(reward3)

        return ContentView()
            .modelContainer(container)
    } catch {
        fatalError(
            "Failed to create ModelContainer for Preview: \(error.localizedDescription)"
        )
    }
}
