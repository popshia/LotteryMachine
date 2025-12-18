//
//  SettingsViewModel.swift
//  LotteryMachine
//
//  Created by Upgrade on 2025/12/12.
//

import Foundation
import SwiftData
import SwiftUI

@Observable
class SettingsViewModel {
    // MARK: - Properties

    var modelContext: ModelContext?

    var isShowingAddRewardSheet = false
    var isEditingReward = false
    var rewardToEdit: Reward?
    var editingRewardName = ""

    var isRenamingCategory = false
    var categoryToRename: String?
    var editingCategoryName = ""

    // MARK: - Initialization
    // We can inject context later or init with it if available,
    // but typically ViewModels in SwiftUI @Observable might get context from View via method calls
    // or init. Here we'll allow setting it or passing it in methods.
    // For simplicity in this app, passing context to methods is often cleaner for SwiftData if we don't hold it long term,
    // but holding it is also fine.

    // MARK: - Actions

    /// Prepares the view model to edit a specific reward.
    ///
    /// - Parameter reward: The reward to edit.
    func prepareEdit(for reward: Reward) {
        rewardToEdit = reward
        editingRewardName = reward.name
        isEditingReward = true
    }

    /// Adds a new reward to the database.
    ///
    /// - Parameters:
    ///   - name: The name of the new reward.
    ///   - category: The category of the new reward.
    ///   - context: The model context to use for adding the reward.
    func addReward(name: String, category: String, context: ModelContext) {
        guard !name.isEmpty else { return }
        let newReward = Reward(name: name, category: category)
        context.insert(newReward)
    }

    /// Edits an existing reward in the database.
    ///
    /// - Parameters:
    ///   - newName: The new name for the reward.
    ///   - context: The model context to use for editing the reward.
    func editReward(newName: String, context: ModelContext) {
        guard let reward = rewardToEdit else { return }
        reward.name = newName
        do {
            try context.save()
        } catch {
            print("Failed to save edited reward: \(error.localizedDescription)")
        }
    }

    /// Deletes a reward from the database.
    ///
    /// - Parameters:
    ///   - reward: The reward to delete.
    ///   - context: The model context to use for deleting the reward.
    func deleteReward(_ reward: Reward, context: ModelContext) {
        // Animation is usually handled in View, but data deletion is here.
        context.delete(reward)
    }

    // MARK: - Category Ordering

    /// Computes the ordered list of categories based on persisted preferences.
    ///
    /// - Parameters:
    ///   - categoryPreferences: The current category preferences from SwiftData.
    ///   - rewards: The list of all rewards.
    /// - Returns: An ordered array of category names.
    func getOrderedCategories(
        categoryPreferences: [CategoryOrderPreference],
        rewards: [Reward]
    ) -> [String] {
        guard let preference = categoryPreferences.first else {
            return Array(Set(rewards.map { $0.category })).sorted()
        }

        // Get all current categories
        let currentCategories = Set(rewards.map { $0.category })

        // Filter saved order to only include categories that still exist
        let savedCategories = preference.categories.filter { currentCategories.contains($0) }

        // Add any new categories that weren't in the saved order
        let newCategories = currentCategories.subtracting(savedCategories).sorted()

        return savedCategories + newCategories
    }

    // MARK: - Category Actions

    /// Prepares the view model to rename a specific category.
    ///
    /// - Parameter category: The category to rename.
    func prepareCategoryRename(category: String) {
        categoryToRename = category
        editingCategoryName = category
        isRenamingCategory = true
    }

    /// Renames a category across all rewards and order preferences.
    ///
    /// - Parameters:
    ///   - newName: The new name for the category.
    ///   - context: The model context for database operations.
    ///   - rewards: All rewards fetched from the view.
    ///   - preferences: Category order preferences fetched from the view.
    func renameCategory(
        newName: String,
        context: ModelContext,
        rewards: [Reward],
        preferences: [CategoryOrderPreference]
    ) {
        guard let oldName = categoryToRename, !newName.isEmpty, oldName != newName else { return }

        // 1. Update all rewards in this category
        let rewardsToUpdate = rewards.filter { $0.category == oldName }
        for reward in rewardsToUpdate {
            reward.category = newName
        }

        // 2. Update category order preferences
        for preference in preferences {
            if let index = preference.categories.firstIndex(of: oldName) {
                preference.categories[index] = newName
                preference.lastUpdated = Date()
            }
        }

        do {
            try context.save()
        } catch {
            print("Failed to rename category: \(error.localizedDescription)")
        }

        categoryToRename = nil
        editingCategoryName = ""
    }
}
