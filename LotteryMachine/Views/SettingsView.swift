//
//  SettingsView.swift
//  LotteryMachine
//
//  Created by Noah on 2025/11/24.
//

import SwiftData
import SwiftUI

/// A view for managing rewards and their candidates.
struct SettingsView: View {
    // MARK: - Environment and Query

    /// The SwiftData model context.
    @Environment(\.modelContext) private var modelContext

    /// A query to fetch all rewards, sorted by category and name.
    @Query(sort: [SortDescriptor(\Reward.category), SortDescriptor(\Reward.name)])
    private var rewards: [Reward]

    // MARK: - State

    /// A boolean to control the presentation of the "Add Reward" sheet.
    @State private var isShowingAddRewardSheet = false

    /// A boolean to control the presentation of the "Edit Reward" alert.
    @State private var isEditingReward = false

    /// The reward currently being edited.
    @State private var rewardToEdit: Reward?

    /// The new name for the reward being edited.
    @State private var editingRewardName = ""

    /// The name for a new candidate, passed to the detail view.
    @State private var newCandidateName = ""

    // MARK: - Computed Properties

    /// A dictionary grouping rewards by their category.
    private var groupedRewards: [String: [Reward]] {
        Dictionary(grouping: rewards, by: { $0.category })
    }

    /// An array of unique, sorted reward categories.
    private var sortedCategories: [String] {
        Array(Set(rewards.map { $0.category })).sorted()
    }

    // MARK: - Body

    /// The content and behavior of the view.
    var body: some View {
        NavigationView {
            VStack {
                // MARK: - Rewards List
                List {
                    ForEach(sortedCategories, id: \.self) { category in
                        Section(header: Text(category.isEmpty ? "Uncategorized" : category)) {
                            ForEach(groupedRewards[category] ?? []) { reward in
                                NavigationLink(
                                    destination: CandidateDetailView(
                                        reward: reward, newCandidateName: $newCandidateName,
                                        addCandidate: addCandidate)
                                ) {
                                    Text(reward.name)
                                }
                                .contextMenu {
                                    Button("編輯") {
                                        rewardToEdit = reward
                                        editingRewardName = reward.name
                                        isEditingReward = true
                                    }
                                    Button("刪除", role: .destructive) {
                                        deleteReward(reward)
                                    }
                                }
                            }
                        }
                    }
                }
                .listStyle(.sidebar)
                .alert("編輯獎項", isPresented: $isEditingReward) {
                    TextField("獎項名稱", text: $editingRewardName)
                    Button("儲存") {
                        if let reward = rewardToEdit {
                            editReward(reward: reward, newName: editingRewardName)
                        }
                    }
                    Button("取消", role: .cancel) {}
                } message: {
                    Text("請輸入新的獎項名稱")
                }

                // MARK: - Add Reward Button
                Button(action: {
                    isShowingAddRewardSheet = true
                }) {
                    Label("新增獎項", systemImage: "plus")
                }
                .padding()
            }
            .navigationTitle("Rewards")
            .sheet(isPresented: $isShowingAddRewardSheet) {
                AddRewardView(
                    isPresented: $isShowingAddRewardSheet,
                    categories: sortedCategories,
                    onSave: { name, category in
                        addReward(name: name, category: category)
                    }
                )
            }
        }
        .frame(minWidth: 600, minHeight: 400)
    }

    // MARK: - Private Methods

    /// Adds a new reward to the model context.
    ///
    /// - Parameters:
    ///   - name: The name of the new reward.
    ///   - category: The category of the new reward.
    private func addReward(name: String, category: String) {
        guard !name.isEmpty else { return }
        let newReward = Reward(name: name, category: category)
        modelContext.insert(newReward)
    }

    /// Edits the name of an existing reward.
    ///
    /// - Parameters:
    ///   - reward: The reward to edit.
    ///   - newName: The new name for the reward.
    private func editReward(reward: Reward, newName: String) {
        reward.name = newName
        do {
            try modelContext.save()
        } catch {
            print("Failed to save edited reward: \(error.localizedDescription)")
        }
    }

    /// Deletes a reward from the model context.
    ///
    /// - Parameter reward: The reward to delete.
    private func deleteReward(_ reward: Reward) {
        withAnimation {
            modelContext.delete(reward)
        }
    }

    /// Adds a new candidate to a reward.
    ///
    /// - Parameter reward: The reward to which the candidate will be added.
    private func addCandidate(to reward: Reward) {
        guard !newCandidateName.isEmpty else { return }
        let newCandidate = Candidate(name: newCandidateName)
        reward.candidates.append(newCandidate)
        newCandidateName = "" // Clear the shared text field
    }
}

/// A view for adding a new reward.
struct AddRewardView: View {
    // MARK: - Bindings and Properties

    /// A binding to control the presentation of the view.
    @Binding var isPresented: Bool

    /// An array of existing categories to choose from.
    let categories: [String]

    /// A closure to be called when the reward is saved.
    let onSave: (String, String) -> Void

    // MARK: - State

    /// The name of the new reward.
    @State private var name: String = ""

    /// The selected category for the new reward.
    @State private var selectedCategory: String = ""

    /// A boolean to indicate whether to create a new category.
    @State private var isNewCategory: Bool = false

    /// The name of the new category.
    @State private var newCategory: String = ""

    // MARK: - Body

    /// The content and behavior of the view.
    var body: some View {
        VStack {
            Text("增加獎項")
                .font(.title)
                .padding()

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
                        // Select the first available category by default
                        selectedCategory = categories.first(where: { !$0.isEmpty }) ?? ""
                    }
                }
            }.padding()

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

/// A view for managing the candidates of a specific reward.
struct CandidateDetailView: View {
    // MARK: - Environment and Bindings

    /// The SwiftData model context.
    @Environment(\.modelContext) private var modelContext

    /// The reward whose candidates are being managed.
    @Bindable var reward: Reward

    /// A boolean to control the presentation of the "Edit Candidate" alert.
    @State private var isEditingCandidate = false

    /// The candidate currently being edited.
    @State private var candidateToEdit: Candidate?

    /// The new name for the candidate being edited.
    @State private var editingCandidateName = ""

    /// A binding to the new candidate's name from the parent view.
    @Binding var newCandidateName: String

    /// A closure to add a new candidate to the reward.
    let addCandidate: (Reward) -> Void

    // MARK: - Body

    /// The content and behavior of the view.
    var body: some View {
        Form {
            Section(header: Text(reward.name).font(.title2).fontWeight(.bold)) {
                HStack {
                    Stepper(
                        "總共抽取: \(reward.numberOfWinners)",
                        value: $reward.numberOfWinners,
                        in: 1...max(1, reward.candidates.count)
                    )
                    .disabled(reward.candidates.isEmpty)
                    .onChange(of: reward.numberOfWinners) {
                        do {
                            try modelContext.save()
                        } catch {
                            print("Failed to save number of winners: \(error)")
                        }
                    }
                    .padding()
                    Button("重置得獎人") {
                        resetWinners(from: reward)
                    }
                    Button("匯入名單") {
                        importCandidatesFromCSV(to: reward)
                    }
                    Button("清除名單") {
                        removeAllCandidates(from: reward)
                    }
                }
            }

            Section(header: Text("得獎人").font(.title2).fontWeight(.bold)) {
                List {
                    ForEach(reward.candidates.sorted(by: { $0.name < $1.name })) { candidate in
                        Text(candidate.name)
                            .foregroundColor(reward.winners.contains(candidate) ? .green : .primary)
                            .contextMenu {
                                Button("編輯") {
                                    candidateToEdit = candidate
                                    editingCandidateName = candidate.name
                                    isEditingCandidate = true
                                }
                                Button("刪除", role: .destructive) {
                                    deleteCandidate(candidate, from: reward)
                                }
                            }
                    }
                }
            }

            HStack {
                TextField("新抽獎人", text: $newCandidateName)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit { addCandidate(reward) }
            }

        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .navigationTitle("Candidates")
        .alert("輸入名字", isPresented: $isEditingCandidate) {
            TextField("同仁名字", text: $editingCandidateName)
            Button("儲存") {
                if let candidate = candidateToEdit {
                    editCandidate(candidate: candidate, newName: editingCandidateName)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
        }
    }

    // MARK: - Private Methods

    /// Resets the list of winners for the reward.
    ///
    /// - Parameter reward: The reward to reset.
    private func resetWinners(from reward: Reward) {
        withAnimation {
            reward.winners.removeAll()
            do {
                try modelContext.save()
            } catch {
                print("Failed to save edited candidate: \(error.localizedDescription)")
            }
        }
    }

    /// Edits the name of a candidate.
    ///
    /// - Parameters:
    ///   - candidate: The candidate to edit.
    ///   - newName: The new name for the candidate.
    private func editCandidate(candidate: Candidate, newName: String) {
        candidate.name = newName
        do {
            try modelContext.save()
        } catch {
            print("Failed to save edited candidate: \(error.localizedDescription)")
        }
    }

    /// Deletes a candidate from a reward.
    ///
    /// - Parameters:
    ///   - candidate: The candidate to delete.
    ///   - reward: The reward from which to delete the candidate.
    private func deleteCandidate(_ candidate: Candidate, from reward: Reward) {
        withAnimation {
            if let index = reward.candidates.firstIndex(where: { $0.id == candidate.id }) {
                reward.candidates.remove(at: index)
            }
            modelContext.delete(candidate)
        }
    }

    /// Imports candidates from a CSV file into the provided reward.
    ///
    /// - Parameter reward: The reward to which candidates will be added.
    private func importCandidatesFromCSV(to reward: Reward) {
        guard let filepath = Bundle.main.path(forResource: "candidates", ofType: "csv") else {
            print("candidates.csv not found")
            return
        }

        do {
            let contents = try String(contentsOfFile: filepath, encoding: .utf8)
            let lines = contents.components(separatedBy: .newlines)

            // Skip the header row if it exists
            let dataLines = lines.dropFirst()

            var existingCandidateNames = Set(reward.candidates.map { $0.name })

            for line in dataLines {
                let columns = line.components(separatedBy: ",")
                if columns.count > 4,
                    !columns[4].trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                {
                    let candidateName = columns[4].trimmingCharacters(in: .whitespacesAndNewlines)
                    if !existingCandidateNames.contains(candidateName) {
                        let newCandidate = Candidate(name: candidateName)
                        reward.candidates.append(newCandidate)
                        existingCandidateNames.insert(candidateName)
                    }
                }
            }
            try modelContext.save()
        } catch {
            print("Error reading or parsing CSV file: \(error.localizedDescription)")
        }
    }

    /// Removes all candidates from the reward.
    ///
    /// - Parameter reward: The reward from which to remove all candidates.
    private func removeAllCandidates(from reward: Reward) {
        withAnimation {
            reward.candidates.removeAll()
            do {
                try modelContext.save()
            } catch {
                print("Failed to save after removing all candidates: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - Preview

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Reward.self, Candidate.self, configurations: config)

        let reward1 = Reward(name: "Christmas Bonus", category: "Holiday", numberOfWinners: 2)
        reward1.candidates.append(Candidate(name: "Noah"))
        reward1.candidates.append(Candidate(name: "Liam"))
        reward1.candidates.append(Candidate(name: "Emma"))

        let reward2 = Reward(name: "Holiday Raffle", category: "Holiday", numberOfWinners: 1)
        reward2.candidates.append(Candidate(name: "Olivia"))
        reward2.candidates.append(Candidate(name: "William"))

        let reward3 = Reward(name: "Q1 Bonus", category: "Quarterly", numberOfWinners: 1)

        container.mainContext.insert(reward1)
        container.mainContext.insert(reward2)
        container.mainContext.insert(reward3)

        return SettingsView()
            .modelContainer(container)
    } catch {
        fatalError("Failed to create ModelContainer for Preview: \(error.localizedDescription)")
    }
}
