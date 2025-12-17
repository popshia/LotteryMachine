//
//  AddRewardView.swift
//  LotteryMachine
//
//  Created by Upgrade on 2025/12/12.
//

import SwiftUI

/// A view for adding a new reward, presented as a sheet.
struct AddRewardView: View {
    // MARK: Bindings and Properties

    /// A binding to control the presentation of the view.
    @Binding var isPresented: Bool

    /// A list of existing categories to choose from.
    let categories: [String]

    /// A closure to execute when the reward is saved.
    let onSave: (String, String) -> Void

    // MARK: State

    /// The name of the new reward.
    @State private var name: String = ""

    /// The selected existing category for the new reward.
    @State private var selectedCategory: String = ""

    /// Indicates whether to create a new category instead of choosing an existing one.
    @State private var isNewCategory: Bool = false

    /// The name of the new category, if `isNewCategory` is true.
    @State private var newCategory: String = ""

    // MARK: Body

    var body: some View {
        VStack {
            Text("增加獎項")
                .font(.title)
                .padding()

            AddRewardFormView(
                name: $name,
                isNewCategory: $isNewCategory,
                selectedCategory: $selectedCategory,
                newCategory: $newCategory,
                categories: categories
            )

            HStack {
                Button("取消") {
                    isPresented = false
                }
                .keyboardShortcut(.cancelAction)

                Spacer()

                Button("儲存") {
                    let finalCategory = isNewCategory ? newCategory : selectedCategory
                    onSave(name, finalCategory)
                    isPresented = false
                }
                .disabled(name.isEmpty)
                .keyboardShortcut(.defaultAction)
            }
            .padding()
        }
        .padding()
        .frame(minWidth: 400, minHeight: 300)
    }
}
