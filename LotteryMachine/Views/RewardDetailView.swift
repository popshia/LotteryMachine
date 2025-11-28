//
//  RewardDetailView.swift
//  LotteryMachine
//
//  Created by Noah on 2025/11/21.
//

import AVFoundation
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

    /// The audio player for the spinning sound effect.
    @State private var spinningPlayer: AVAudioPlayer?
    
    /// The audio player for the finish sound effect.
    @State private var finishPlayer: AVAudioPlayer?
    
    /// The audio player for the tick sound effect.
    @State private var tickPlayer: AVAudioPlayer?

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
                    Text(
                        reward.winners
                            .map(\.name)
                            .joined(separator: ", ")
                    )
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
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
                        // The confetti will disappear after 5 seconds.
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
        spinningPlayer = playSound(named: "spinning.mp3", loop: true)
        var availableCandidates = reward.candidates

        /// Recursively draws the next winner until the desired number of winners is reached.
        func drawNextWinner() {
            if reward.winners.count >= reward.numberOfWinners
                || availableCandidates.isEmpty
            {
                isDrawing = false
                stopSound(spinningPlayer)
                spinningPlayer = nil
                finishPlayer = playSound(named: "finish.mp3")
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
                    playTick()
                }

                // Draw the next winner after a short delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    drawNextWinner()
                }
            }
        }

        drawNextWinner()
    }

    /// Plays a sound from the main bundle.
    ///
    /// - Parameters:
    ///   - name: The name of the sound file.
    ///   - loop: A boolean indicating whether the sound should loop.
    /// - Returns: An `AVAudioPlayer` instance, or `nil` if the sound file is not found or fails to play.
    private func playSound(
        named name: String,
        loop: Bool = false
    ) -> AVAudioPlayer? {
        guard let url = Bundle.main.url(forResource: name, withExtension: nil) else {
            print("Audio file not found:", name)
            return nil
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = loop ? -1 : 0
            if name == "finish.mp3" {
                player.volume = 0.4
            } else {
                player.volume = 0.7
            }
            player.prepareToPlay()
            player.play()
            return player
        } catch {
            print("Failed to create AVAudioPlayer:", error.localizedDescription)
            return nil
        }
    }

    /// Plays the tick sound effect.
    private func playTick() {
        if tickPlayer == nil {
            guard let url = Bundle.main.url(forResource: "tick.mp3", withExtension: nil) else {
                return
            }
            tickPlayer = try? AVAudioPlayer(contentsOf: url)
            tickPlayer?.volume = 0.5
            tickPlayer?.prepareToPlay()
        }

        tickPlayer?.currentTime = 0
        tickPlayer?.play()
    }

    /// Stops the specified audio player.
    ///
    /// - Parameter player: The audio player to stop.
    private func stopSound(_ player: AVAudioPlayer?) {
        player?.stop()
    }
}
