//
//  Models.swift
//  LotteryMachine
//
//  Created by Noah on 2025/11/21.
//

import SwiftData

@Model
class Reward {
    var name: String
    var candidates: [Candidate]
    var winners: [Candidate] = []

    init(name: String = "", candidates: [Candidate] = [], winners: [Candidate] = []) {
        self.name = name
        self.candidates = candidates
        self.winners = winners
    }
}

@Model
class Candidate {
    var name: String

    init(name: String = "") {
        self.name = name
    }
}
