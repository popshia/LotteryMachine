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
    @Query(sort: \Reward.name)
    private var rewards: [Reward]

    @State private var newRewardName = ""
    @State private var newCandidateName = ""

    var body: some View {
        NavigationView {
            VStack {
                List {
                    Section {
                        ForEach(rewards) { reward in
                            NavigationLink(
                                destination: candidateDetailView(for: reward)
                            ) {
                                Text(reward.name)
                            }
                            .contextMenu {
                                Button("Delete") {
                                    if let index = rewards.firstIndex(where: {
                                        $0.id == reward.id
                                    }) {
                                        deleteRewards(
                                            offsets: IndexSet(integer: index)
                                        )
                                    }
                                }
                            }
                        }
                    } header: {
                        Text("Rewards")
                    }
                }
                .listStyle(.sidebar)

                HStack {
                    TextField("New Reward", text: $newRewardName)
                        .textFieldStyle(.roundedBorder)
                        .onSubmit(addReward)

                    Button(action: addReward) {
                        Image(systemName: "plus")
                    }
                    .disabled(newRewardName.isEmpty)
                }
                .padding()
            }
            .navigationTitle("Rewards")
        }
        .frame(minWidth: 600, minHeight: 400)
    }

    @ViewBuilder
    private func candidateDetailView(for reward: Reward) -> some View {
        Form {
            Section {
                List {
                    ForEach(reward.candidates.sorted(by: { $0.name < $1.name }))
                    { candidate in
                        Text(candidate.name)
                            .contextMenu {
                                Button("Delete") {
                                    deleteCandidate(candidate, from: reward)
                                }
                            }
                    }
                }
            } header: {
                Text("Candidates for \(reward.name)")
            }

            HStack {
                TextField("New Candidate", text: $newCandidateName)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit { addCandidate(to: reward) }
                Button(action: { addCandidate(to: reward) }) {
                    Image(systemName: "plus")
                }
                .disabled(newCandidateName.isEmpty)
            }
        }
        .padding()
        .navigationTitle("Candidates")
    }

    private func addReward() {
        guard !newRewardName.isEmpty else { return }
        let newReward = Reward(name: newRewardName, candidates: [])
        modelContext.insert(newReward)
        newRewardName = ""
    }

    private func deleteRewards(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(rewards[index])
            }
        }
    }

    private func addCandidate(to reward: Reward) {
        guard !newCandidateName.isEmpty else {
            return
        }
        let newCandidate = Candidate(name: newCandidateName)
        reward.candidates.append(newCandidate)
        newCandidateName = ""
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
        let container = try ModelContainer(
            for: Reward.self,
            Candidate.self,
            configurations: config
        )

        let reward1 = Reward(name: "Christmas Bonus", candidates: [])
        reward1.candidates.append(Candidate(name: "Noah"))
        reward1.candidates.append(Candidate(name: "Liam"))
        reward1.candidates.append(Candidate(name: "Emma"))

        let reward2 = Reward(name: "Holiday Raffle", candidates: [])
        reward2.candidates.append(Candidate(name: "Olivia"))
        reward2.candidates.append(Candidate(name: "William"))

        container.mainContext.insert(reward1)
        container.mainContext.insert(reward2)

        return SettingsView()
            .modelContainer(container)
    } catch {
        fatalError(
            "Failed to create ModelContainer for Preview: \\(error.localizedDescription)"
        )
    }
}
