//
//  Models.swift
//  LotteryMachine
//
//  Created by Noah on 2025/11/21.
//

import Foundation

struct Reward: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var candidates: [Candidate]
    var winners: [Candidate] = []
}

struct Candidate: Identifiable, Hashable {
    let id = UUID()
    var name: String
}
