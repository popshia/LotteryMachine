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
                .font(.largeTitle)
                .padding()
        }
        .frame(width: 180, height: 100)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(
                    isWinner
                        ? Color.green.opacity(0.3)
                        : (isHighlighted
                            ? Color.yellow.opacity(0.5)
                            : Color.blue.opacity(0.1))
                )
                .shadow(
                    color: isHighlighted ? .yellow : .clear,
                    radius: isHighlighted ? 10 : 0
                )
        )
        .scaleEffect(isHighlighted ? 1.1 : 1.0)
        .animation(.easeInOut, value: isHighlighted)
    }
}
