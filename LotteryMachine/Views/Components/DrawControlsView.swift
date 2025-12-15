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
    let reward: Reward
    let allRewards: [Reward]
    let theme: SeasonalTheme
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme

    @State private var isHoveringDrawButton = false

    var body: some View {
        HStack {
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
            Stepper(
                "抽取間隔: \(String(format: "%.1f", viewModel.spinningDuration)) 秒",
                value: $viewModel.spinningDuration,
                in: 0.5...10,
                step: 0.5
            )
            .font(.title.bold())
            .padding(.horizontal)
        }
    }
}
