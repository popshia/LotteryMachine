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
        reward.isDrawn = false
        saveChanges(context: context)
    }

    func importCandidatesFromCSV(to reward: Reward, context: ModelContext) {
        print("Importing candidates from CSV...")
        guard let filepath = Bundle.main.path(forResource: "candidates_final", ofType: "csv") else {
            print("candidates_final.csv not found")
            return
        }

        do {
            let contents = try String(contentsOfFile: filepath, encoding: .utf8)
            let rows = contents.components(separatedBy: .newlines)
            let headerColumns = rows.first?.components(separatedBy: ",") ?? []
            let dataRows = rows.dropFirst()

            func columnValues(column: String) -> [String] {
                guard let index = headerColumns.firstIndex(where: { $0.contains(column) }) else {
                    return []
                }

                return dataRows.compactMap { row in
                    let columns = row.components(separatedBy: ",")
                    guard index < columns.count else { return nil }
                    let value = columns[index].trimmingCharacters(in: .whitespacesAndNewlines)
                    return value.isEmpty ? nil : value
                }
            }

            let correspondCandidateNames = columnValues(column: reward.category)

            for name in correspondCandidateNames {
                let newCandidate = Candidate(name: name)
                reward.candidates.append(newCandidate)
            }
            saveChanges(context: context)
        } catch {
            print("Error reading or parsing CSV file: \(error.localizedDescription)")
        }
    }

    func resetAllData(rewards: [Reward], context: ModelContext) throws {
        // 1. Pre-load and parse CSV to ensure it exists and is valid before deleting anything
        guard let filepath = Bundle.main.path(forResource: "candidates_final", ofType: "csv") else {
            throw NSError(
                domain: "CandidateDetailViewModel", code: 404,
                userInfo: [NSLocalizedDescriptionKey: "candidates_final.csv not found"])
        }

        let contents = try String(contentsOfFile: filepath, encoding: .utf8)
        let rows = contents.components(separatedBy: .newlines)
        let headerColumns = rows.first?.components(separatedBy: ",") ?? []
        // Clean headers to ensure accurate matching
        let cleanHeaders = headerColumns.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

        let dataRows = rows.dropFirst()

        // Helper to get column data from parsed rows
        func getValues(forColumnIndex index: Int) -> [String] {
            return dataRows.compactMap { row in
                let columns = row.components(separatedBy: ",")
                guard index < columns.count else { return nil }
                let value = columns[index].trimmingCharacters(in: .whitespacesAndNewlines)
                return value.isEmpty ? nil : value
            }
        }

        // 2. Perform Batch Reset
        for reward in rewards.filter({ $0.category != "總經理獎遊戲" }) {
            // Logic matching resetWinners
            reward.winners.removeAll()
            reward.isDrawn = false

            // Logic matching removeAllCandidates
            for candidate in reward.candidates {
                context.delete(candidate)
            }
            reward.candidates.removeAll()

            // Logic matching importCandidatesFromCSV
            // Find column index for this reward's category
            // Note: Original logic used `contains`, so we replicate that flexible matching
            if let index = cleanHeaders.firstIndex(where: { $0.contains(reward.category) }) {
                let candidateNames = getValues(forColumnIndex: index)
                for name in candidateNames {
                    let newCandidate = Candidate(name: name)
                    reward.candidates.append(newCandidate)
                }
            }
        }

        // 3. Single Save
        saveChanges(context: context)
    }

    private func saveChanges(context: ModelContext) {
        do {
            try context.save()
        } catch {
            print("Failed to save changes: \(error.localizedDescription)")
        }
    }
}
