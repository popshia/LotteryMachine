//
//  DrawControlsView.swift
//  LotteryMachine
//
//  Created by Upgrade on 2025/12/15.
//

import SwiftData
import SwiftUI

struct DrawControlsView: View {
    @Bindable var viewModel: RewardDetailViewModel
    @Bindable var contentViewModel: ContentViewModel
    let reward: Reward
    let allRewards: [Reward]
    let theme: SeasonalTheme
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme

    @State private var isHoveringDrawButton = false
    @State private var isHoveringPrevButton = false
    @State private var isHoveringNextButton = false

    /// The index of the current reward in the allRewards array.
    private var currentIndex: Int? {
        allRewards.firstIndex(where: { $0.id == reward.id })
    }

    /// Whether there is a previous reward to navigate to.
    private var hasPreviousReward: Bool {
        guard let index = currentIndex else { return false }
        return index > 0
    }

    /// Whether there is a next reward to navigate to.
    private var hasNextReward: Bool {
        guard let index = currentIndex else { return false }
        return index < allRewards.count - 1
    }

    var body: some View {
        HStack {
            // MARK: Previous Reward Button
            Button(action: {
                if let index = currentIndex, index > 0 {
                    contentViewModel.selectedReward = allRewards[index - 1]
                }
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                    Text("上一獎項")
                }
                .font(.title2.bold())
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(theme.gold.opacity(hasPreviousReward ? 0.9 : 0.3))
                )
                .foregroundColor(.white)
            }
            .buttonStyle(.borderless)
            .scaleEffect(isHoveringPrevButton && hasPreviousReward ? 1.05 : 1.0)
            .animation(
                .spring(response: 0.25, dampingFraction: 0.75),
                value: isHoveringPrevButton
            )
            .onHover { hovering in
                isHoveringPrevButton = hovering
            }
            .disabled(!hasPreviousReward)
            .padding(.trailing, 8)

            // MARK: Draw Winner Button
            Button(action: {
                viewModel.drawWinner(
                    reward: reward, allRewards: allRewards, context: modelContext)
            }) {
                Text("從 \(reward.candidates.count) 位中抽取 \(reward.numberOfWinners) 位得獎者")
                    .font(.largeTitle.bold())
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

            // MARK: Stepper
            Stepper(
                "抽取間隔: \(String(format: "%.1f", viewModel.spinningDuration)) 秒",
                value: $viewModel.spinningDuration,
                in: 0.1...10,
                step: 0.1
            )
            .font(.title.bold())
            .padding(.horizontal)

            // MARK: Next Reward Button
            Button(action: {
                if let index = currentIndex, index < allRewards.count - 1 {
                    contentViewModel.selectedReward = allRewards[index + 1]
                }
            }) {
                HStack(spacing: 4) {
                    Text("下一獎項")
                    Image(systemName: "chevron.right")
                }
                .font(.title2.bold())
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(theme.gold.opacity(hasNextReward ? 0.9 : 0.3))
                )
                .foregroundColor(.white)
            }
            .buttonStyle(.borderless)
            .scaleEffect(isHoveringNextButton && hasNextReward ? 1.05 : 1.0)
            .animation(
                .spring(response: 0.25, dampingFraction: 0.75),
                value: isHoveringNextButton
            )
            .onHover { hovering in
                isHoveringNextButton = hovering
            }
            .disabled(!hasNextReward)
            .padding(.leading, 8)
        }
    }
}
