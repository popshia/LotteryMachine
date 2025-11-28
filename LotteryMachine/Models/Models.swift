//
//  Models.swift
//  LotteryMachine
//
//  Created by Noah on 2025/11/21.
//

import SwiftData

// MARK: - Reward

/// A model representing a lottery reward.
@Model
class Reward {
    /// The name of the reward.
    var name: String
    
    /// The category of the reward (e.g., "Holiday", "Quarterly").
    var category: String
    
    /// The number of winners for this reward.
    var numberOfWinners: Int
    
    /// A list of candidates eligible for this reward.
    /// When a reward is deleted, all its associated candidates are also deleted.
    @Relationship(deleteRule: .cascade)
    var candidates: [Candidate]
    
    /// A list of candidates who have won this reward.
    var winners: [Candidate] = []

    /// Initializes a new reward.
    ///
    /// - Parameters:
    ///   - name: The name of the reward. Defaults to an empty string.
    ///   - category: The category of the reward. Defaults to an empty string.
    ///   - numberOfWinners: The number of winners. Defaults to 1.
    ///   - candidates: The list of eligible candidates. Defaults to an empty array.
    ///   - winners: The list of winners. Defaults to an empty array.
    init(
        name: String = "",
        category: String = "",
        numberOfWinners: Int = 1,
        candidates: [Candidate] = [],
        winners: [Candidate] = []
    ) {
        self.name = name
        self.category = category
        self.numberOfWinners = numberOfWinners
        self.candidates = candidates
        self.winners = winners
    }
}

// MARK: - Candidate

/// A model representing a candidate in the lottery.
@Model
class Candidate {
    /// The name of the candidate.
    var name: String

    /// Initializes a new candidate.
    ///
    /// - Parameter name: The name of the candidate. Defaults to an empty string.
    init(name: String = "") {
        self.name = name
    }
}
