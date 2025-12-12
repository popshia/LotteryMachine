//
//  RewardDetailView.swift
//  LotteryMachine
//
//  Created by Upgrade on 2025/11/21.
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

    // MARK: - ViewModel

    @State private var viewModel = RewardDetailViewModel()

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
                            isHighlighted: viewModel.highlightedCandidate == candidate,
                            isWinner: reward.winners.contains(candidate)
                        )
                    }
                }
                .padding()
            }

            // MARK: Controls
            HStack {
                Button(action: {
                    viewModel.drawWinner(
                        reward: reward, allRewards: allRewards, context: modelContext)
                }) {
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
                                    .opacity(viewModel.isDrawing ? 0.35 : 1.0)
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
                .disabled(viewModel.isDrawing || reward.candidates.isEmpty)
                .padding()
                Stepper(
                    "抽取秒數: \(String(format: "%.1f", viewModel.spinningDuration))s",
                    value: $viewModel.spinningDuration,
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
            ForEach(viewModel.confettiBursts, id: \.self) { id in
                ConfettiView()
                    .allowsHitTesting(false)
                    .onAppear {
                        // The confetti will disappear after 5 seconds.
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                            viewModel.cleanUpConfetti(id: id)
                        }
                    }
            }
        )
    }

    // MARK: - State (Local to View for non-logic UI stuff)

    @State private var isHoveringDrawButton = false
}
