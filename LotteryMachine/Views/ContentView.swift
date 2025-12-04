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
    // MARK: - Environment

    /// The SwiftData model context, used for interacting with the data store.
    @Environment(\.modelContext) private var modelContext

    /// The current color scheme (light/dark mode), used for theme adjustments.
    @Environment(\.colorScheme) private var colorScheme

    // MARK: - Data

    /// A query to fetch all rewards from SwiftData, sorted by category and name.
    @Query(sort: [
        SortDescriptor(\Reward.category), SortDescriptor(\Reward.name),
    ])
    private var rewards: [Reward]

    /// The currently selected reward in the list.
    @State private var selectedReward: Reward?

    // MARK: - Properties

    /// The theme instance for styling the view.
    private let theme: SeasonalTheme = ChineseNewYearTheme()

    /// A computed property that groups rewards by their category for display.
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
            // MARK: Rewards List
            List(selection: $selectedReward) {
                ForEach(sortedCategories, id: \.self) { category in
                    Section(
                        header:
                            // Section header with category name
                            Text(category.isEmpty ? "Uncategorized" : category)
                            .font(.title2.weight(.bold))
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
                            .padding(.vertical, 6)
                    ) {
                        ForEach(groupedRewards[category] ?? []) { reward in
                            // Reward item in the list
                            HStack {
                                Image(systemName: "sparkles")
                                    .foregroundStyle(theme.gold)
                                Text(reward.name)
                                    .font(.title.weight(.semibold))
                                Image(systemName: "sparkles")
                                    .foregroundStyle(theme.gold)
                                // Label {
                                //     Text(reward.name)
                                //         .font(.title.weight(.semibold))
                                // } icon: {
                                //     Image(systemName: "sparkles")
                                //         .foregroundStyle(theme.gold)
                                // }
                            }
                            .tag(reward)
                        }
                    }
                }
            }
            .listStyle(SidebarListStyle())
            .scrollContentBackground(.hidden) // Hide default list background
            .background(theme.background(for: colorScheme))
            .shadow(radius: 10)
            .tint(theme.gold) // Set the accent color for the list
            .navigationTitle("Lottery Machine")
        } detail: {
            // MARK: Detail View
            ZStack {
                // Background for the detail view
                theme.background(for: colorScheme)
                    .ignoresSafeArea()

                if let selectedReward {
                    // Display the detail view for the selected reward
                    RewardDetailView(reward: selectedReward)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // Placeholder text when no reward is selected
                    let message =
                        rewards.isEmpty
                        ? "請到設定裡增加尾牙獎項"
                        : "請選擇一個獎項以查看詳細資訊"

                    Text(message)
                        .font(.largeTitle.bold())
                        .foregroundColor(.primary)
                }
            }
        }
        .navigationSplitViewStyle(.balanced)
        .toolbarBackground(
            theme.background(for: colorScheme).opacity(0.95),
            for: .windowToolbar
        )
    }
}

// MARK: - Preview

#if DEBUG
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            do {
                let config = ModelConfiguration(isStoredInMemoryOnly: true)
                let container = try ModelContainer(
                    for: Reward.self,
                    Candidate.self,
                    configurations: config
                )

                // Create sample data for the preview
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

                // Insert sample data into the container
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
    }
#endif
