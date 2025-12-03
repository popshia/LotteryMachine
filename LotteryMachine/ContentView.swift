//
//  ContentView.swift
//  LotteryMachine
//
//  Created by Noah on 2025/11/21.
//

import SwiftData
import SwiftUI

/// The main view of the app, displaying a list of rewards and their details.
struct ContentView: View {
    // MARK: - Properties

    /// The SwiftData model context.
    @Environment(\.modelContext) private var modelContext

    /// The current color scheme (light/dark mode).
    @Environment(\.colorScheme) private var colorScheme

    /// A query to fetch all rewards from SwiftData, sorted by category and name.
    @Query(sort: [
        SortDescriptor(\Reward.category), SortDescriptor(\Reward.name),
    ])
    private var rewards: [Reward]

    /// The currently selected reward in the list.
    @State private var selectedReward: Reward?

    /// The theme instance for styling.
    private let theme: SeasonalTheme = ChineseNewYearTheme()

    /// A computed property that groups rewards by their category.
    private var groupedRewards: [String: [Reward]] {
        Dictionary(grouping: rewards, by: { $0.category })
    }

    /// A computed property that returns a sorted list of reward categories.
    private var sortedCategories: [String] {
        groupedRewards.keys.sorted()
    }

    // MARK: - Body

    var body: some View {
        NavigationSplitView {
            VStack {
                Text("C-LINK · 尾牙抽獎")
                    .font(.title2.weight(.bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        ZStack {
                            LinearGradient(
                                colors: [
                                    theme.red(for: colorScheme),
                                    theme.darkRed(for: colorScheme),
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )

                            GoldShimmer(gold: theme.gold)
                                .opacity(NSApp?.keyWindow != nil ? 1.0 : 0.35)
                        }
                    )
                // MARK: - Rewards List
                List(selection: $selectedReward) {
                    ForEach(sortedCategories, id: \.self) { category in
                        Section(
                            header: Text(
                                category.isEmpty ? "Uncategorized" : category
                            )
                            .font(.title3.weight(.bold))
                            .foregroundStyle(theme.darkRed(for: colorScheme))
                            .padding(.vertical, 6)
                            .padding(.horizontal, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(theme.red(for: colorScheme).opacity(0.08))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(theme.gold.opacity(0.6), lineWidth: 1)
                            )
                        ) {
                            ForEach(groupedRewards[category] ?? []) { reward in
                                HStack {
                                    Label {
                                        Text(reward.name)
                                            .font(.title2.weight(.semibold))
                                    } icon: {
                                        Image(systemName: "sparkles")
                                            .foregroundStyle(theme.gold)
                                    }
                                    Image(systemName: "sparkles")
                                        .foregroundStyle(theme.gold)
                                }
                                .tag(reward)
                            }
                        }
                    }
                }
                .listStyle(SidebarListStyle())
                .scrollContentBackground(.hidden)
                .background(theme.background(for: colorScheme))
                .tint(theme.gold)
            }
            .navigationTitle("Lottery Machine")
        } detail: {
            ZStack {
                if let selectedReward {
                    RewardDetailView(
                        reward: selectedReward
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(
                        Image("background")
                            .resizable()
                            .scaledToFill()
                            .opacity(0.4)
                    )
                } else {
                    if rewards.isEmpty {
                        Text("請到設定裡增加尾牙獎項")
                            .font(.largeTitle)
                    } else {
                        Text("請選擇一個獎項以查看詳細資訊")
                            .font(.largeTitle)
                    }
                }
            }
        }
        .accentColor(theme.gold)
    }
}

// MARK: - Preview

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
