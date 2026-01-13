//
//  ContentViewModel.swift
//  LotteryMachine
//
//  Created by Upgrade on 2025/12/17.
//

import Foundation
import SwiftData
import SwiftUI
import UniformTypeIdentifiers

@Observable
class ContentViewModel {
    // MARK: - Properties

    /// The currently selected reward in the list.
    var selectedReward: Reward?

    /// Generates a CSV string of winners in a columnar format matching the input CSV header structure.
    /// Columns are distinct Rewards (Category + Name), and rows list the winners.
    ///
    /// - Parameter rewards: The list of rewards to export.
    /// - Returns: A CSV formatted string.
    func generateExportCSV(from rewards: [Reward]) -> String {
        // 1. Group winners by "Category - RewardName"
        // We need to fetch all distinct reward types (Category + Name)
        // because multiple Reward objects might represent the same prize type or be separate slots.
        // We'll treat unique (Category, Name) pairs as columns.

        struct RewardKey: Hashable, Comparable {
            let category: String
            let name: String

            static func < (lhs: RewardKey, rhs: RewardKey) -> Bool {
                if lhs.category != rhs.category {
                    return lhs.category < rhs.category
                }
                return lhs.name < rhs.name
            }

            var header: String {
                "\(category) - \(name)"
            }
        }

        var columnData: [RewardKey: [String]] = [:]

        // Group rewards
        for reward in rewards {
            let key = RewardKey(category: reward.category, name: reward.name)
            let winnerNames = reward.winners.map { $0.name }
            columnData[key, default: []].append(contentsOf: winnerNames)
        }

        let sortedKeys = columnData.keys.sorted()

        // 2. Determine max number of rows needed
        let maxRows = columnData.values.map { $0.count }.max() ?? 0

        // 3. Construct CSV Header
        var csvString = sortedKeys.map { $0.header }.joined(separator: ",") + "\n"

        // 4. Construct Rows
        for i in 0..<maxRows {
            var rowValues: [String] = []
            for key in sortedKeys {
                let winners = columnData[key] ?? []
                if i < winners.count {
                    // Escape commas if necessary
                    let name = winners[i]
                    if name.contains(",") || name.contains("\"") || name.contains("\n") {
                        let escaped = name.replacingOccurrences(of: "\"", with: "\"\"")
                        rowValues.append("\"\(escaped)\"")
                    } else {
                        rowValues.append(name)
                    }
                } else {
                    rowValues.append("") // Empty cell
                }
            }
            csvString += rowValues.joined(separator: ",") + "\n"
        }

        return csvString
    }

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
