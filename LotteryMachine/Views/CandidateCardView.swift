//
//  CandidateCardView.swift
//  LotteryMachine
//
//  Created by Noah on 2025/11/21.
//

import SwiftUI

/// A view that displays a candidate's name on a card with visual effects for highlighting and winning.
struct CandidateCardView: View {
    // MARK: - Properties

    /// The candidate to display.
    let candidate: Candidate

    /// A boolean indicating whether the card should be highlighted.
    let isHighlighted: Bool

    /// A boolean indicating whether the candidate is a winner.
    let isWinner: Bool

    /// The theme instance for styling.
    private let theme: SeasonalTheme = ChineseNewYearTheme()

    // MARK: - Body

    var body: some View {
        Text(candidate.name)
            .font(.system(size: 40).bold())
            .foregroundStyle(theme.darkRed(for: .light))
            .padding()
            .frame(width: 180, height: 100)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(
                        isWinner
                            ? Color.red.opacity(0.4)
                            : (isHighlighted
                                ? Color.yellow.opacity(0.8)
                                : theme.red(for: .light).opacity(0.08))
                    )
                    .shadow(
                        color: isHighlighted ? .yellow : .clear,
                        radius: isHighlighted ? 10 : 0
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(theme.gold.opacity(0.8), lineWidth: 4)
                    )
            )
            .scaleEffect(isHighlighted ? 1.2 : 1.0)
            .animation(.easeInOut, value: isHighlighted)
    }
}
//.font(.title2.weight(.bold))
//    .padding(.vertical, 6)
//    .padding(.horizontal, 10)
//    .background(
//        RoundedRectangle(cornerRadius: 8)
//            .fill(theme.red(for: colorScheme).opacity(0.08))
//    )
//    .overlay(
//        RoundedRectangle(cornerRadius: 8)
//            .stroke(theme.gold.opacity(0.6), lineWidth: 1)
//    )
