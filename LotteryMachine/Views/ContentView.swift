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

    /// A query to fetch the category order preference from SwiftData.
    @Query private var categoryPreferences: [CategoryOrderPreference]

    // MARK: - ViewModel

    /// The view model managing business logic for this view.
    @State private var viewModel = ContentViewModel()

    /// State to control the visibility of the settings sheet.
    @State private var isShowingSettings = false

    // MARK: - Properties

    /// The theme instance for styling the view.
    private let theme: SeasonalTheme = ChineseNewYearTheme()

    /// A computed property that groups rewards by their category for display.
    private var groupedRewards: [String: [Reward]] {
        Dictionary(grouping: rewards, by: { $0.category })
    }

    /// A computed property that returns the ordered list of categories.
    /// Uses persisted order from SwiftData if available, otherwise falls back to sorted keys.
    private var orderedCategories: [String] {
        viewModel.getOrderedCategories(
            categoryPreferences: categoryPreferences,
            groupedRewards: groupedRewards
        )
    }

    // MARK: - Body

    var body: some View {
        NavigationSplitView {
            // MARK: Rewards List
            List {
                ForEach(orderedCategories, id: \.self) { category in
                    Section(
                        header: CategoryHeaderView(category: category, theme: theme)
                    ) {
                        ForEach(groupedRewards[category] ?? []) { reward in
                            RewardRowView(reward: reward, theme: theme)
                                .tag(reward)
                                .padding(.vertical, 2)
                                .padding(.horizontal, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(
                                            viewModel.selectedReward?.id == reward.id
                                                ? theme.gold : Color.clear, lineWidth: 2)
                                )
                                .onTapGesture {
                                    viewModel.selectedReward = reward
                                }
                        }
                    }
                }
                .onMove { from, to in
                    viewModel.saveCategoryOrder(
                        from: from,
                        to: to,
                        orderedCategories: orderedCategories,
                        categoryPreferences: categoryPreferences,
                        context: modelContext
                    )
                }
            }
            .onAppear {
                viewModel.initializeCategoryPreference(
                    categoryPreferences: categoryPreferences,
                    groupedRewards: groupedRewards,
                    context: modelContext
                )
            }
            .listStyle(SidebarListStyle())
            .scrollContentBackground(.hidden) // Hide default list background
            .background(theme.background(for: colorScheme))
            .shadow(radius: 10)
            .tint(theme.gold) // Hide default selection color to use our custom one
            .navigationTitle("Lottery Machine")
        } content: {
            // MARK: Content View
            ZStack {
                // Background for the detail view
                theme.background(for: colorScheme)
                    .ignoresSafeArea()

                if let selectedReward = viewModel.selectedReward {
                    // Display the detail view for the selected reward
                    RewardDetailView(reward: selectedReward)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    RewardDetailPlaceholderView(rewards: rewards, theme: theme)
                }
            }
        } detail: {
            // MARK: Detail View
            ZStack {
                theme.background(for: colorScheme)
                    .ignoresSafeArea()
                Text("等值商品可參考如下")
                    .font(.largeTitle.bold())
                    .foregroundColor(.primary)
            }
        }
        .navigationSplitViewStyle(.balanced)
        .toolbarBackground(
            theme.background(for: colorScheme).opacity(0.95),
            for: .windowToolbar
        )
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button(action: {
                    isShowingSettings = true
                }) {
                    Label("Settings", systemImage: "gearshape")
                        .foregroundColor(theme.red(for: colorScheme))
                }
                .buttonStyle(.automatic)
                .help("Open Settings")
            }
        }
        .sheet(isPresented: $isShowingSettings) {
            SettingsView()
                .frame(minWidth: 800, minHeight: 600)
                .preferredColorScheme(.light)
        }
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
