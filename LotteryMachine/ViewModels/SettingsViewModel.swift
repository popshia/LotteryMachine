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

    // MARK: - Initialization
    // We can inject context later or init with it if available,
    // but typically ViewModels in SwiftUI @Observable might get context from View via method calls
    // or init. Here we'll allow setting it or passing it in methods.
    // For simplicity in this app, passing context to methods is often cleaner for SwiftData if we don't hold it long term,
    // but holding it is also fine.

    // MARK: - Actions

    func prepareEdit(for reward: Reward) {
        rewardToEdit = reward
        editingRewardName = reward.name
        isEditingReward = true
    }

    func addReward(name: String, category: String, context: ModelContext) {
        guard !name.isEmpty else { return }
        let newReward = Reward(name: name, category: category)
        context.insert(newReward)
    }

    func editReward(newName: String, context: ModelContext) {
        guard let reward = rewardToEdit else { return }
        reward.name = newName
        do {
            try context.save()
        } catch {
            print("Failed to save edited reward: \(error.localizedDescription)")
        }
    }

    func deleteReward(_ reward: Reward, context: ModelContext) {
        // Animation is usually handled in View, but data deletion is here.
        context.delete(reward)
    }
}
