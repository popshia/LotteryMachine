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
    let candidateModel: CandidateDetailViewModel
    @State private var showingResetConfirmation = false

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

            }
            .navigationTitle("獎項管理")
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
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button(action: {
                    viewModel.isShowingAddRewardSheet = true
                }) {
                    Label("新增獎項", systemImage: "plus")
                }
                .foregroundStyle(.blue)
                .buttonStyle(.automatic)
            }
            ToolbarItem(placement: .automatic) {
                Button(role: .destructive) {
                    showingResetConfirmation = true
                } label: {
                    Label("重置系統", systemImage: "arrow.clockwise")
                }
                .foregroundStyle(.red)
                .buttonStyle(.automatic)
            }
        }
        .sheet(isPresented: $viewModel.isShowingAddRewardSheet) {
            AddRewardView(
                isPresented: $viewModel.isShowingAddRewardSheet,
                categories: sortedCategories,
                onSave: { name, category in
                    viewModel.addReward(name: name, category: category, context: modelContext)
                }
            )
        }
        .alert("Reset system", isPresented: $showingResetConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) {
                do {
                    try candidateModel.resetAllData(rewards: rewards, context: modelContext)
                } catch {
                    // In a real app we might want to show this error to the user
                    print("Reset failed: \(error.localizedDescription)")
                }
            }
        } message: {
            Text(
                "Are you sure you want to reset all data? This action cannot be undone."
            )
        }
    }
}
