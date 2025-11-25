//
//  SettingsView.swift
//  LotteryMachine
//
//  Created by Noah on 2025/11/24.
//

import SwiftData
import SwiftUI

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\Reward.category), SortDescriptor(\Reward.name)])
    private var rewards: [Reward]

    // State for add reward sheet
    @State private var isShowingAddRewardSheet = false

    // State for editing a reward
    @State private var isEditingReward = false
    @State private var rewardToEdit: Reward?
    @State private var editingRewardName = ""

    // State for adding new candidates (passed to detail view)
    @State private var newCandidateName = ""

    private var groupedRewards: [String: [Reward]] {
        Dictionary(grouping: rewards, by: { $0.category })
    }

    private var sortedCategories: [String] {
        // Return unique, sorted categories
        Array(Set(rewards.map { $0.category })).sorted()
    }

    var body: some View {
        NavigationView {
            VStack {
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
                                    Button("Edit") {
                                        rewardToEdit = reward
                                        editingRewardName = reward.name
                                        isEditingReward = true
                                    }
                                    Button("Delete", role: .destructive) {
                                        deleteReward(reward)
                                    }
                                }
                            }
                        }
                    }
                }
                .listStyle(.sidebar)
                .alert("Edit Reward", isPresented: $isEditingReward) {
                    TextField("New Name", text: $editingRewardName)
                    Button("Save") {
                        if let reward = rewardToEdit {
                            editReward(reward: reward, newName: editingRewardName)
                        }
                    }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("Enter a new name for the reward.")
                }

                Button(action: {
                    isShowingAddRewardSheet = true
                }) {
                    Label("Add Reward", systemImage: "plus")
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

    private func addReward(name: String, category: String) {
        guard !name.isEmpty else { return }
        let newReward = Reward(name: name, category: category)
        modelContext.insert(newReward)
    }

    private func editReward(reward: Reward, newName: String) {
        reward.name = newName
        do {
            try modelContext.save()
        } catch {
            print("Failed to save edited reward: \(error.localizedDescription)")
        }
    }

    private func deleteReward(_ reward: Reward) {
        withAnimation {
            modelContext.delete(reward)
        }
    }

    private func addCandidate(to reward: Reward) {
        guard !newCandidateName.isEmpty else { return }
        let newCandidate = Candidate(name: newCandidateName)
        reward.candidates.append(newCandidate)
        newCandidateName = "" // Clear the shared text field
    }
}

struct AddRewardView: View {
    @Binding var isPresented: Bool
    let categories: [String]
    let onSave: (String, String) -> Void

    @State private var name: String = ""
    @State private var selectedCategory: String = ""
    @State private var isNewCategory: Bool = false
    @State private var newCategory: String = ""

    var body: some View {
        VStack {
            Text("Add New Reward")
                .font(.title)
                .padding()

            Form {
                TextField("Reward Name", text: $name)
                Toggle("Create new category?", isOn: $isNewCategory.animation())

                if isNewCategory {
                    TextField("New Category Name", text: $newCategory)
                } else {
                    Picker("Category", selection: $selectedCategory) {
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
                Button("Cancel") {
                    isPresented = false
                }
                .keyboardShortcut(.cancelAction)

                Spacer()

                Button("Save") {
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

struct CandidateDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var reward: Reward

    // State for editing a candidate
    @State private var isEditingCandidate = false
    @State private var candidateToEdit: Candidate?
    @State private var editingCandidateName = ""

    // Bindings and closures from parent
    @Binding var newCandidateName: String
    let addCandidate: (Reward) -> Void

    var body: some View {
        Form {
            Section(header: Text(reward.name).font(.title2).fontWeight(.bold)) {
                Stepper(
                    "Number of Winners: \(reward.numberOfWinners)",
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
            }

            Section(header: Text("Candidates").font(.title2).fontWeight(.bold)) {
                List {
                    ForEach(reward.candidates.sorted(by: { $0.name < $1.name })) { candidate in
                        Text(candidate.name)
                            .foregroundColor(reward.winners.contains(candidate) ? .green : .primary)
                            .contextMenu {
                                Button("Edit") {
                                    candidateToEdit = candidate
                                    editingCandidateName = candidate.name
                                    isEditingCandidate = true
                                }
                                Button("Delete", role: .destructive) {
                                    deleteCandidate(candidate, from: reward)
                                }
                            }
                    }
                }
            }

            HStack {
                TextField("New Candidate", text: $newCandidateName)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit { addCandidate(reward) }
            }

        }
        .frame(maxWidth: .infinity, alignment: .leading) // Apply leading alignment here
        .padding() // Keep outer padding
        .navigationTitle("Candidates")
        .alert("Enter a new name", isPresented: $isEditingCandidate) {
            TextField("New Name", text: $editingCandidateName)
            Button("Save") {
                if let candidate = candidateToEdit {
                    editCandidate(candidate: candidate, newName: editingCandidateName)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
        }
    }

    private func deleteCandidates(offsets: IndexSet) {
        withAnimation {
            // Need to map offsets to the sorted array
            let sortedCandidates = reward.candidates.sorted(by: { $0.name < $1.name })
            offsets.forEach { index in
                let candidateToDelete = sortedCandidates[index]
                modelContext.delete(candidateToDelete)
            }
        }
    }

    private func editCandidate(candidate: Candidate, newName: String) {
        candidate.name = newName
        do {
            try modelContext.save()
        } catch {
            print("Failed to save edited candidate: \(error.localizedDescription)")
        }
    }

    private func deleteCandidate(_ candidate: Candidate, from reward: Reward) {
        withAnimation {
            if let index = reward.candidates.firstIndex(where: { $0.id == candidate.id }) {
                reward.candidates.remove(at: index)
            }
            modelContext.delete(candidate)
        }
    }
}

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
