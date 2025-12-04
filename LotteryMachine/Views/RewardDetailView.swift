//
//  RewardDetailView.swift
//  LotteryMachine
//
//  Created by Noah on 2025/11/21.
//

import AVFoundation
import SwiftData
import SwiftUI

/// A view that displays the details of a reward, including the candidates and the winner drawing animation.
struct RewardDetailView: View {
    // MARK: - Properties

    /// The reward being displayed.
    var reward: Reward

    /// A query to fetch all rewards from SwiftData. This is used to remove winners from other reward categories.
    @Query private var allRewards: [Reward]

    /// The SwiftData model context, used for saving changes.
    @Environment(\.modelContext) private var modelContext

    // MARK: - State

    /// Indicates whether the winner drawing animation is in progress.
    @State private var isDrawing = false

    /// The candidate currently being highlighted during the drawing animation.
    @State private var highlightedCandidate: Candidate?

    /// The duration of the spinning animation for each winner, adjustable by the user.
    @State private var spinningDuration = 1.0

    /// A list of IDs to trigger confetti bursts, each corresponding to a win event.
    @State private var confettiBursts: [UUID] = []

    /// Indicates whether the user is hovering over the draw button, used for visual feedback.
    @State private var isHoveringDrawButton = false

    // MARK: - Audio

    /// The audio player for the continuous spinning sound effect.
    @State private var spinningPlayer: AVAudioPlayer?

    /// The audio player for the sound effect when a winner is announced.
    @State private var finishPlayer: AVAudioPlayer?

    /// The audio player for the ticking sound during the highlight phase.
    @State private var tickPlayer: AVAudioPlayer?

    // MARK: - Styling

    /// The theme instance for styling the view.
    private let theme: SeasonalTheme = ChineseNewYearTheme()

    /// The current color scheme (light/dark mode).
    @Environment(\.colorScheme) private var colorScheme

    /// The columns for the candidate grid, making the layout adaptive.
    let columns = [
        GridItem(.adaptive(minimum: 200))
    ]

    // MARK: - Body

    var body: some View {
        VStack {
            // MARK: Header
            Text("💵 \(reward.name) * \(reward.numberOfWinners)位 💵")
                .font(.system(size: 72))
                .fontWeight(.bold)
                .padding()

            // MARK: Winners Display
            if !reward.winners.isEmpty {
                VStack {
                    Text("🎉 中獎者 🎉")
                    Text(
                        reward.winners
                            .map(\.name)
                            .joined(separator: "    ")
                    )
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                }
                .padding()
                .breathingContainer(
                    backgroundColor: .red, borderColor: theme.gold, cornerRadius: 12
                )
                .padding()
                .font(.system(size: 60))
                .transition(.scale)
            }

            // MARK: Candidates Grid
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

            // MARK: Controls
            HStack {
                Button(action: drawWinner) {
                    Text("開始抽獎")
                        .font(.largeTitle)
                        .padding()
                        .background(
                            ZStack {
                                LinearGradient(
                                    colors: [
                                        theme.red(for: colorScheme),
                                        theme.darkRed(for: colorScheme),
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )

                                GoldShimmer(gold: theme.gold)
                                    .opacity(isDrawing ? 0.35 : 1.0)
                            }
                        )
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .buttonStyle(.borderless)
                .scaleEffect(isHoveringDrawButton ? 1.06 : 1.0)
                .animation(
                    .spring(response: 0.25, dampingFraction: 0.75),
                    value: isHoveringDrawButton
                )
                .onHover { hovering in
                    isHoveringDrawButton = hovering
                }
                .disabled(isDrawing || reward.candidates.isEmpty)
                .padding()
                Stepper(
                    "抽取秒數: \(String(format: "%.1f", spinningDuration))s",
                    value: $spinningDuration,
                    in: 0.5...10,
                    step: 0.5
                )
                .font(.title.bold())
                .padding(.horizontal)
            }

            Spacer()
        }
        .navigationTitle("C-Link 尾牙抽獎")
        .overlay(
            // Display confetti bursts when winners are drawn.
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
    /// This is used during the spinning animation to prevent highlighting the same candidate consecutively.
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
            // Stop if enough winners have been drawn or if there are no more candidates.
            if reward.winners.count >= reward.numberOfWinners
                || availableCandidates.isEmpty
            {
                isDrawing = false
                stopSound(spinningPlayer)
                spinningPlayer = nil
                finishPlayer = playSound(named: "finish.mp3")
                confettiBursts.append(UUID()) // Trigger confetti
                return
            }

            let highlightDelay = 0.1
            let numberOfHighlights = Int(spinningDuration / highlightDelay)

            // Animate highlighting different candidates before selecting a winner.
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

            // Select the winner after the animation.
            DispatchQueue.main.asyncAfter(deadline: .now() + spinningDuration) {
                guard let winner = availableCandidates.randomElement() else {
                    isDrawing = false
                    return
                }

                // Remove the winner from the list of available candidates for this reward.
                availableCandidates.removeAll { $0.id == winner.id }

                withAnimation(.spring()) {
                    reward.winners.append(winner)
                    highlightedCandidate = nil
                    playTick() // Play a sound for the selection
                }

                // Remove the winner from all other rewards to prevent winning multiple times.
                for otherReward in allRewards where otherReward.id != reward.id {
                    otherReward.candidates.removeAll { $0.name == winner.name }
                }

                // Save the changes to SwiftData.
                do {
                    try modelContext.save()
                } catch {
                    print("Failed to save context: \(error)")
                }

                // Draw the next winner after a short delay.
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

    /// Plays the tick sound effect. This is reused to avoid re-initializing the player.
    private func playTick() {
        // Initialize the player if it hasn't been already.
        if tickPlayer == nil {
            guard let url = Bundle.main.url(forResource: "tick.mp3", withExtension: nil) else {
                return
            }
            tickPlayer = try? AVAudioPlayer(contentsOf: url)
            tickPlayer?.volume = 0.5
            tickPlayer?.prepareToPlay()
        }

        // Play the sound from the beginning.
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
