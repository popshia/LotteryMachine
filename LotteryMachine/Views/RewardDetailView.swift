//
//  RewardDetailView.swift
//  LotteryMachine
//
//  Created by Noah on 2025/11/21.
//

import SwiftUI

struct RewardDetailView: View {
    var reward: Reward

    @State private var isDrawing = false
    @State private var highlightedCandidate: Candidate?
    @State private var spinningDuration = 1.0
    @State private var confettiBursts: [UUID] = []

    let columns = [
        GridItem(.adaptive(minimum: 200))
    ]

    var body: some View {
        VStack {
            HStack {
                Text("\(reward.name) * \(reward.numberOfWinners)")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
            }

            if !reward.winners.isEmpty {
                VStack {
                    Text("🎉 Winner\(reward.winners.count > 1 ? "s" : "") 🎉")
                        .font(.title)
                    HStack {
                        ForEach(reward.winners) { winner in
                            Text(winner.name)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                                .padding(.vertical, 2)
                        }
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
                    ForEach(
                        reward.candidates.sorted {
                            $0.name.localizedCaseInsensitiveCompare($1.name)
                                == .orderedAscending
                        }
                    ) { candidate in
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
                Stepper(
                    "Spinning Duration: \(String(format: "%.1f", spinningDuration))s",
                    value: $spinningDuration,
                    in: 0.5...10,
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
        .navigationTitle("C-Link 尾牙抽獎")
        .overlay(
            ForEach(confettiBursts, id: \.self) { id in
                ConfettiView()
                    .allowsHitTesting(false)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                            confettiBursts.removeAll { $0 == id }
                        }
                    }
            }
        )
    }

    private func randomDifferentElement<T: Equatable>(
        from array: [T],
        excluding current: T?
    ) -> T? {
        let filtered = array.filter { $0 != current }
        return filtered.randomElement() ?? array.randomElement()
    }

    private func drawWinner() {
        guard !reward.candidates.isEmpty else { return }

        isDrawing = true
        reward.winners = []
        var availableCandidates = reward.candidates

        func drawNextWinner() {
            if reward.winners.count >= reward.numberOfWinners
                || availableCandidates.isEmpty
            {
                isDrawing = false
                confettiBursts.append(UUID())
                return
            }

            let highlightDelay = 0.1
            let numberOfHighlights = Int(spinningDuration / highlightDelay)

            for i in 0..<numberOfHighlights {
                DispatchQueue.main.asyncAfter(
                    deadline: .now() + Double(i) * highlightDelay
                ) {
                    withAnimation {
                        highlightedCandidate = randomDifferentElement(
                            from: availableCandidates,
                            excluding: highlightedCandidate
                        )
                    }
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + spinningDuration) {
                guard let winner = availableCandidates.randomElement() else {
                    isDrawing = false
                    return
                }

                availableCandidates.removeAll { $0.id == winner.id }

                withAnimation(.spring()) {
                    reward.winners.append(winner)
                    highlightedCandidate = nil
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    drawNextWinner()
                }
            }
        }

        drawNextWinner()
    }
}
