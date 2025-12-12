//
//  SettingsView.swift
//  LotteryMachine
//
//  Created by Upgrade on 2025/12/12.
//

import SwiftData
import SwiftUI

/// A view for managing rewards and their candidates.
struct SettingsView: View {
    // MARK: - Environment and Query

    /// The SwiftData model context for database operations.
    @Environment(\.modelContext) private var modelContext

    /// A query to fetch all rewards, sorted by category and name.
    @Query(sort: [SortDescriptor(\Reward.category), SortDescriptor(\Reward.name)])
    private var rewards: [Reward]

    // MARK: - ViewModel

    @State private var viewModel = SettingsViewModel()

    // MARK: - Computed Properties

    /// A dictionary grouping rewards by their category for organized display.
    private var groupedRewards: [String: [Reward]] {
        Dictionary(grouping: rewards, by: { $0.category })
    }

    /// An array of unique, sorted reward categories.
    private var sortedCategories: [String] {
        Array(Set(rewards.map { $0.category })).sorted()
    }

    // MARK: - Body

    var body: some View {
        NavigationView {
            VStack {
                // MARK: Rewards List
                List {
                    ForEach(sortedCategories, id: \.self) { category in
                        Section(header: Text(category.isEmpty ? "Uncategorized" : category)) {
                            ForEach(groupedRewards[category] ?? []) { reward in
                                NavigationLink(
                                    destination: CandidateDetailView(reward: reward)
                                ) {
                                    Text(reward.name)
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
                    }
                }
                .listStyle(.sidebar)
                .alert("編輯獎項", isPresented: $viewModel.isEditingReward) {
                    TextField("獎項名稱", text: $viewModel.editingRewardName)
                    Button("儲存") {
                        viewModel.editReward(
                            newName: viewModel.editingRewardName, context: modelContext)
                    }
                    Button("取消", role: .cancel) {}
                } message: {
                    Text("請輸入新的獎項名稱")
                }

                // MARK: Add Reward Button
                Button(action: {
                    viewModel.isShowingAddRewardSheet = true
                }) {
                    Label("新增獎項", systemImage: "plus")
                }
                .padding()
            }
            .navigationTitle("Rewards")
            .sheet(isPresented: $viewModel.isShowingAddRewardSheet) {
                AddRewardView(
                    isPresented: $viewModel.isShowingAddRewardSheet,
                    categories: sortedCategories,
                    onSave: { name, category in
                        viewModel.addReward(name: name, category: category, context: modelContext)
                    }
                )
            }
        }
        .frame(minWidth: 600, minHeight: 400)
    }
}

// MARK: - Preview

#if DEBUG
    struct SettingsView_Previews: PreviewProvider {
        static var previews: some View {
            do {
                let config = ModelConfiguration(isStoredInMemoryOnly: true)
                let container = try ModelContainer(
                    for: Reward.self, Candidate.self, configurations: config)

                // Sample data for preview
                let reward1 = Reward(
                    name: "Christmas Bonus", category: "Holiday", numberOfWinners: 2)
                reward1.candidates.append(Candidate(name: "Noah"))
                reward1.candidates.append(Candidate(name: "Liam"))
                reward1.candidates.append(Candidate(name: "Emma"))

                let reward2 = Reward(
                    name: "Holiday Raffle", category: "Holiday", numberOfWinners: 1)
                reward2.candidates.append(Candidate(name: "Olivia"))
                reward2.candidates.append(Candidate(name: "William"))

                let reward3 = Reward(name: "Q1 Bonus", category: "Quarterly", numberOfWinners: 1)

                // Insert data into the context
                container.mainContext.insert(reward1)
                container.mainContext.insert(reward2)
                container.mainContext.insert(reward3)

                return SettingsView()
                    .modelContainer(container)
            } catch {
                fatalError(
                    "Failed to create ModelContainer for Preview: \(error.localizedDescription)")
            }
        }
    }
#endif
