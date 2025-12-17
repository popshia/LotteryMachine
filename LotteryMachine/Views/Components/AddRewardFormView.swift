//
//  AddRewardFormView.swift
//  LotteryMachine
//
//  Created by Upgrade on 2025/12/17.
//

import SwiftUI

/// A reusable form component for adding a new reward.
struct AddRewardFormView: View {
    // MARK: - Bindings

    /// The name of the new reward.
    @Binding var name: String

    /// Indicates whether to create a new category.
    @Binding var isNewCategory: Bool

    /// The selected existing category.
    @Binding var selectedCategory: String

    /// The name of the new category.
    @Binding var newCategory: String

    /// List of existing categories.
    let categories: [String]

    // MARK: - Body

    var body: some View {
        Form {
            TextField("獎項名稱", text: $name)

            Toggle("新獎項類別?", isOn: $isNewCategory.animation())

            if isNewCategory {
                TextField("新獎項類別", text: $newCategory)
            } else {
                Picker("獎項類別", selection: $selectedCategory) {
                    ForEach(categories.filter { !$0.isEmpty }, id: \.self) { category in
                        Text(category).tag(category)
                    }
                }
                .onAppear {
                    // Default to the first available category
                    if selectedCategory.isEmpty {
                        selectedCategory = categories.first(where: { !$0.isEmpty }) ?? ""
                    }
                }
            }
        }
        .padding()
    }
}
