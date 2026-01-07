//
//  CandidateDetailViewModel.swift
//  LotteryMachine
//
//  Created by Upgrade on 2025/12/12.
//

import Foundation
import SwiftData
import SwiftUI

@Observable
class CandidateDetailViewModel {
    // MARK: - Properties

    var isEditingCandidate = false
    var candidateToEdit: Candidate?
    var editingCandidateName = ""
    var newCandidateName = ""

    // MARK: - Actions

    func addCandidate(to reward: Reward, context: ModelContext) {
        guard !newCandidateName.isEmpty else { return }
        let newCandidate = Candidate(name: newCandidateName)
        reward.candidates.append(newCandidate)
        newCandidateName = ""
        // No explicit save needed usually with autosave, but we can if we want to be sure
    }

    func prepareEdit(for candidate: Candidate) {
        candidateToEdit = candidate
        editingCandidateName = candidate.name
        isEditingCandidate = true
    }

    func editCandidate(newName: String, context: ModelContext) {
        guard let candidate = candidateToEdit else { return }
        candidate.name = newName
        saveChanges(context: context)
    }

    func deleteCandidate(_ candidate: Candidate, from reward: Reward, context: ModelContext) {
        if let index = reward.candidates.firstIndex(where: { $0.id == candidate.id }) {
            reward.candidates.remove(at: index)
            context.delete(candidate)
            saveChanges(context: context)
        }
    }

    func removeAllCandidates(from reward: Reward, context: ModelContext) {
        for candidate in reward.candidates {
            context.delete(candidate)
        }
        reward.candidates.removeAll()
        saveChanges(context: context)
    }

    func resetWinners(from reward: Reward, context: ModelContext) {
        reward.winners.removeAll()
        saveChanges(context: context)
    }

    func importCandidatesFromCSV(to reward: Reward, context: ModelContext) {
        guard let filepath = Bundle.main.path(forResource: "candidates", ofType: "csv") else {
            print("candidates.csv not found")
            return
        }

        do {
            let contents = try String(contentsOfFile: filepath, encoding: .utf8)
            let lines = contents.components(separatedBy: .newlines)
            let dataLines = lines.dropFirst()

            var existingCandidateNames = Set(reward.candidates.map { $0.name })

            for line in dataLines {
                let columns = line.components(separatedBy: ",")

                guard columns.count == 7 else {
                    print("Invalid line: \(line)")
                    continue
                }
                let candidateName = columns[4].trimmingCharacters(
                    in: .whitespacesAndNewlines)

                guard !candidateName.isEmpty else {
                    print("Invalid candidate name: \(candidateName)")
                    continue
                }
                guard !existingCandidateNames.contains(candidateName) else {
                    print("Duplicate candidate name: \(candidateName)")
                    continue
                }

                let newCandidate = Candidate(name: candidateName)
                reward.candidates.append(newCandidate)
                existingCandidateNames.insert(candidateName)
            }
            saveChanges(context: context)
        } catch {
            print("Error reading or parsing CSV file: \(error.localizedDescription)")
        }
    }

    private func saveChanges(context: ModelContext) {
        do {
            try context.save()
        } catch {
            print("Failed to save changes: \(error.localizedDescription)")
        }
    }
}
