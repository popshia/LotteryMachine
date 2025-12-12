//
//  CandidateDetailView.swift
//  LotteryMachine
//
//  Created by Upgrade on 2025/12/12.
//

import SwiftData
import SwiftUI

/// A view for managing the candidates of a specific reward.
struct CandidateDetailView: View {
    // MARK: Environment and Bindings

    /// The SwiftData model context.
    @Environment(\.modelContext) private var modelContext

    /// The reward whose candidates are being managed.
    @Bindable var reward: Reward

    // MARK: - ViewModel

    @State private var viewModel = CandidateDetailViewModel()

    // MARK: Body

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
                        // Save changes when number of winners changes
                        try? modelContext.save()
                    }
                    .padding()

                    Button("重置得獎人") {
                        viewModel.resetWinners(from: reward, context: modelContext)
                    }
                    Button("匯入名單") {
                        viewModel.importCandidatesFromCSV(to: reward, context: modelContext)
                    }
                    Button("清除名單") {
                        viewModel.removeAllCandidates(from: reward, context: modelContext)
                    }
                }
            }

            Section(header: Text("候選人名單").font(.title2).fontWeight(.bold)) {
                List {
                    ForEach(reward.candidates.sorted(by: { $0.name < $1.name })) { candidate in
                        Text(candidate.name)
                            .foregroundColor(reward.winners.contains(candidate) ? .green : .primary)
                            .contextMenu {
                                Button("編輯") {
                                    viewModel.prepareEdit(for: candidate)
                                }
                                Button("刪除", role: .destructive) {
                                    viewModel.deleteCandidate(
                                        candidate, from: reward, context: modelContext)
                                }
                            }
                    }
                }
            }

            HStack {
                TextField("新抽獎人", text: $viewModel.newCandidateName)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit {
                        viewModel.addCandidate(to: reward, context: modelContext)
                    }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .navigationTitle("Candidates")
        .alert("輸入名字", isPresented: $viewModel.isEditingCandidate) {
            TextField("同仁名字", text: $viewModel.editingCandidateName)
            Button("儲存") {
                viewModel.editCandidate(
                    newName: viewModel.editingCandidateName, context: modelContext)
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("請輸入名字")
        }
    }
}
