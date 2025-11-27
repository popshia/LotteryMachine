//
//  RewardDetailView.swift
//  LotteryMachine
//
//  Created by Noah on 2025/11/21.
//

import SwiftUI

/// A view that displays the details of a reward, including the candidates and the winner drawing animation.
struct RewardDetailView: View {
    // MARK: - Properties
    
    /// The reward to display.
    var reward: Reward

    /// A boolean indicating whether the winner drawing animation is in progress.
    @State private var isDrawing = false
    
    /// The candidate currently being highlighted during the drawing animation.
    @State private var highlightedCandidate: Candidate?
    
    /// The duration of the spinning animation for each winner.
    @State private var spinningDuration = 1.0
    
    /// A list of IDs to trigger confetti bursts.
    @State private var confettiBursts: [UUID] = []

    /// The columns for the candidate grid.
    let columns = [
        GridItem(.adaptive(minimum: 200))
    ]

    // MARK: - Body
    
    var body: some View {
        VStack {
            // MARK: - Header
            HStack {
                Text("\(reward.name) * \(reward.numberOfWinners)")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
            }

            // MARK: - Winners Display
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

            // MARK: - Candidates Grid
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

            // MARK: - Controls
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

    // MARK: - Private Methods
    
    /// Returns a random element from an array, ensuring it's different from the provided element.
    ///
    /// - Parameters:
    ///   - array: The array to select from.
    ///   - current: The element to exclude.
    /// - Returns: A random element from the array, or `nil` if the array is empty.
    private func randomDifferentElement<T: Equatable>(
        from array: [T],
        excluding current: T?
    ) -> T? {
        let filtered = array.filter { $0 != current }
        return filtered.randomElement() ?? array.randomElement()
    }

    /// Starts the process of drawing a winner.
    private func drawWinner() {
        guard !reward.candidates.isEmpty else { return }

        isDrawing = true
        reward.winners = []
        var availableCandidates = reward.candidates

        /// Recursively draws the next winner until the desired number of winners is reached.
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

            // Animation of highlighting candidates
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

            // Select the winner after the animation
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

                // Draw the next winner after a short delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    drawNextWinner()
                }
            }
        }

        drawNextWinner()
    }
}
