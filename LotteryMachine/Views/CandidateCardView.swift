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

    // MARK: - Body

    var body: some View {
        VStack {
            Text(candidate.name)
                .font(.system(size: 40))
                .bold()
                .padding()
        }
        .frame(width: 180, height: 100)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(
                    isWinner
                        ? Color.red.opacity(0.6)
                        : (isHighlighted
                            ? Color.yellow.opacity(0.8)
                            : Color.white)
                )
                .shadow(
                    color: isHighlighted ? .yellow : .clear,
                    radius: isHighlighted ? 10 : 0
                )
        )
        .scaleEffect(isHighlighted ? 1.2 : 1.0)
        .animation(.easeInOut, value: isHighlighted)
    }
}
