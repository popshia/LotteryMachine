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

    /// Environment variable to dismiss the view when presented as a sheet.
    @Environment(\.dismiss) private var dismiss

    /// A query to fetch all rewards, sorted by category and name.
    @Query(sort: [SortDescriptor(\Reward.category), SortDescriptor(\Reward.name)])
    private var rewards: [Reward]

    /// A query to fetch the category order preference from SwiftData.
    @Query private var categoryPreferences: [CategoryOrderPreference]

    // MARK: - ViewModel

    @State private var viewModel = SettingsViewModel()

    // MARK: - Computed Properties

    /// A dictionary grouping rewards by their category for organized display.
    private var groupedRewards: [String: [Reward]] {
        Dictionary(grouping: rewards, by: { $0.category })
    }

    /// An array of unique, sorted reward categories.
    /// Uses persisted order from SwiftData if available, matching ContentView's ordering.
    private var sortedCategories: [String] {
        viewModel.getOrderedCategories(
            categoryPreferences: categoryPreferences,
            rewards: rewards
        )
    }

    // MARK: - Body

    var body: some View {
        NavigationView {
            VStack {
                // MARK: Rewards List
                List {
                    ForEach(sortedCategories, id: \.self) { category in
                        Section(
                            header: Text(category.isEmpty ? "Uncategorized" : category)
                                .font(.title3)
                                .contextMenu {
                                    Button {
                                        viewModel.prepareCategoryRename(category: category)
                                    } label: {
                                        Label("編輯類別名稱", systemImage: "pencil")
                                    }
                                }
                        ) {
                            ForEach(groupedRewards[category] ?? []) { reward in
                                SettingsRewardRowView(reward: reward, viewModel: viewModel)
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
                    .buttonStyle(.glass)
                    Button("取消", role: .cancel) {}
                        .buttonStyle(.glass)
                } message: {
                    Text("請輸入新的獎項名稱")
                }
                .alert("編輯類別名稱", isPresented: $viewModel.isRenamingCategory) {
                    TextField("類別名稱", text: $viewModel.editingCategoryName)
                    Button("儲存") {
                        viewModel.renameCategory(
                            newName: viewModel.editingCategoryName,
                            context: modelContext,
                            rewards: rewards,
                            preferences: categoryPreferences
                        )
                    }
                    .buttonStyle(.glass)
                    Button("取消", role: .cancel) {}
                        .buttonStyle(.glass)
                } message: {
                    Text("請輸入新的類別名稱")
                }

                // MARK: Add Reward Button
                Button(action: {
                    viewModel.isShowingAddRewardSheet = true
                }) {
                    Label("新增獎項", systemImage: "plus")
                }
                .padding()
            }
            .navigationTitle("獎項管理")
            .sheet(isPresented: $viewModel.isShowingAddRewardSheet) {
                AddRewardView(
                    isPresented: $viewModel.isShowingAddRewardSheet,
                    categories: sortedCategories,
                    onSave: { name, category in
                        viewModel.addReward(name: name, category: category, context: modelContext)
                    }
                )
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .buttonStyle(.glass)
                }
            }
        }
        .frame(minWidth: 600, minHeight: 600)
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
