//
//  CandidateCardView.swift
//  LotteryMachine
//
//  Created by Noah on 2025/11/21.
//

import SwiftUI

struct CandidateCardView: View {
    let candidate: Candidate
    let isHighlighted: Bool
    let isWinner: Bool

    var body: some View {
        VStack {
            Text(candidate.name)
                .font(.title)
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
