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
                CandidateManagementToolsView(reward: reward, viewModel: viewModel)
            }

            Toggle("是否為群獎", isOn: $reward.isGroupReward)
                .toggleStyle(.switch)

            Section(
                header: Text("獎池名單").font(.title2).fontWeight(.bold) + Text(" (").font(.body)
                    + Text("\(reward.candidates.count)").font(.body) + Text(")").font(.body)
            ) {
                CandidateListView(reward: reward, viewModel: viewModel)
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
        .navigationTitle("編輯獎品")
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
