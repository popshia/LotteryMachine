//
//  ContentViewModel.swift
//  LotteryMachine
//
//  Created by Upgrade on 2025/12/17.
//

import Foundation
import SwiftData
import SwiftUI

@Observable
class ContentViewModel {
    // MARK: - Properties

    /// The currently selected reward in the list.
    var selectedReward: Reward?

    // MARK: - Category Order Management

    /// Initializes the category preference in SwiftData if it doesn't exist.
    ///
    /// - Parameters:
    ///   - categoryPreferences: The current category preferences from SwiftData.
    ///   - groupedRewards: The rewards grouped by category.
    ///   - context: The SwiftData model context.
    func initializeCategoryPreference(
        categoryPreferences: [CategoryOrderPreference],
        groupedRewards: [String: [Reward]],
        context: ModelContext
    ) {
        // If no preference exists, create one with the current sorted categories
        if categoryPreferences.isEmpty {
            let initialCategories = groupedRewards.keys.sorted()
            let preference = CategoryOrderPreference(categories: initialCategories)
            context.insert(preference)
            try? context.save()
        }
    }

    /// Saves the new category order to SwiftData after a drag-and-drop operation.
    ///
    /// - Parameters:
    ///   - from: The source indices of the moved items.
    ///   - to: The destination index.
    ///   - orderedCategories: The current ordered list of categories.
    ///   - categoryPreferences: The current category preferences from SwiftData.
    ///   - context: The SwiftData model context.
    func saveCategoryOrder(
        from: IndexSet,
        to: Int,
        orderedCategories: [String],
        categoryPreferences: [CategoryOrderPreference],
        context: ModelContext
    ) {
        // Get the current ordered categories
        var newOrder = orderedCategories

        // Perform the move operation
        newOrder.move(fromOffsets: from, toOffset: to)

        // Update or create the preference
        if let preference = categoryPreferences.first {
            preference.categories = newOrder
            preference.lastUpdated = Date()
        } else {
            let preference = CategoryOrderPreference(categories: newOrder)
            context.insert(preference)
        }

        // Save to SwiftData
        try? context.save()
    }

    /// Computes the ordered list of categories based on persisted preferences.
    ///
    /// - Parameters:
    ///   - categoryPreferences: The current category preferences from SwiftData.
    ///   - groupedRewards: The rewards grouped by category.
    /// - Returns: An ordered array of category names.
    func getOrderedCategories(
        categoryPreferences: [CategoryOrderPreference],
        groupedRewards: [String: [Reward]]
    ) -> [String] {
        guard let preference = categoryPreferences.first else {
            return groupedRewards.keys.sorted()
        }

        // Get all current categories
        let currentCategories = Set(groupedRewards.keys)

        // Filter saved order to only include categories that still exist
        let savedCategories = preference.categories.filter { currentCategories.contains($0) }

        // Add any new categories that weren't in the saved order
        let newCategories = currentCategories.subtracting(savedCategories).sorted()

        return savedCategories + newCategories
    }
}
