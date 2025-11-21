//
//  RewardDetailView.swift
//  LotteryMachine
//
//  Created by Noah on 2025/11/21.
//


import SwiftUI

struct RewardDetailView: View {
    @Binding var reward: Reward
    @Binding var newCandidateName: String

    @State private var isDrawing = false
    @State private var highlightedCandidate: Candidate?
    @State private var numberOfWinners = 1
    @State private var spinningDuration = 3.0

    let columns = [
        GridItem(.adaptive(minimum: 200))
    ]

    var body: some View {
        VStack {
            Text(reward.name)
                .font(.largeTitle)
                .padding()

            if !reward.winners.isEmpty {
                VStack {
                    Text("🎉 Winner\(reward.winners.count > 1 ? "s" : "") 🎉")
                        .font(.title)
                        .padding()
                    ForEach(reward.winners) { winner in
                        Text(winner.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                            .padding(.vertical, 2)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10).fill(
                        Color.yellow.opacity(0.2)
                    )
                )
                .transition(.scale)
            }

            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(reward.candidates) { candidate in
                        CandidateCardView(
                            candidate: candidate,
                            isHighlighted: highlightedCandidate == candidate,
                            isWinner: reward.winners.contains(candidate)
                        )
                    }
                }
                .padding()
            }

            HStack {
                TextField("New Candidate", text: $newCandidateName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onSubmit { addCandidate() }
            }
            .padding()

            HStack {
                Stepper(
                    "Number of Winners: \(numberOfWinners)",
                    value: $numberOfWinners,
                    in: 1...max(1, reward.candidates.count)
                )
                .padding(.horizontal)
                .disabled(
                    isDrawing || reward.candidates.isEmpty
                        || reward.candidates.count == 1
                )

                Stepper(
                    "Spinning Duration: \(String(format: "%.1f", spinningDuration))s",
                    value: $spinningDuration,
                    in: 1...10,
                    step: 0.5
                )
                .padding(.horizontal)
            }

            Button(action: drawWinner) {
                Text("Draw Winner")
                    .font(.largeTitle)
                    .padding()
                    .background(isDrawing ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .buttonStyle(.borderless)
            .disabled(isDrawing || reward.candidates.isEmpty)
            .padding()

            Spacer()
        }
        .navigationTitle(reward.name)
    }

    private func addCandidate() {
        if !newCandidateName.isEmpty {
            reward.candidates.append(Candidate(name: newCandidateName))
            newCandidateName = ""
        }
    }

    private func drawWinner() {
        guard !reward.candidates.isEmpty else { return }

        isDrawing = true
        reward.winners = []

        let highlightDelay = 0.1
        let numberOfHighlights = Int(spinningDuration / highlightDelay)

        for i in 0..<numberOfHighlights {
            DispatchQueue.main.asyncAfter(
                deadline: .now() + Double(i) * highlightDelay
            ) {
                withAnimation {
                    highlightedCandidate = reward.candidates.randomElement()
                }
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + spinningDuration) {
            withAnimation(.spring()) {
                reward.winners = Array(
                    reward.candidates.shuffled().prefix(numberOfWinners)
                )
                highlightedCandidate = nil
            }
            isDrawing = false
        }
    }
}