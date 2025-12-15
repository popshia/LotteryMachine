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
                WinnersDisplayView(reward: reward, theme: theme)
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
            DrawControlsView(
                viewModel: viewModel,
                reward: reward,
                allRewards: allRewards,
                theme: theme
            )

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
}
