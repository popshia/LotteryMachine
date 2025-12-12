//
//  RewardDetailViewModel.swift
//  LotteryMachine
//
//  Created by Upgrade on 2025/12/12.
//

import AVFoundation
import Foundation
import SwiftData
import SwiftUI

@Observable
class RewardDetailViewModel {
    // MARK: - Properties

    var isDrawing = false
    var highlightedCandidate: Candidate?
    var spinningDuration = 1.0
    var confettiBursts: [UUID] = []

    // MARK: - Audio
    private var spinningPlayer: AVAudioPlayer?
    private var finishPlayer: AVAudioPlayer?
    private var tickPlayer: AVAudioPlayer?

    // MARK: - Actions

    func drawWinner(reward: Reward, allRewards: [Reward], context: ModelContext) {
        guard !reward.candidates.isEmpty else { return }

        isDrawing = true
        reward.winners = []
        spinningPlayer = playSound(named: "spinning.mp3", loop: true)

        // We need a local copy to pick from?
        // Original logic: var availableCandidates = reward.candidates
        // But if we want to support multiple winners, we need to track it properly across recursive calls.
        // In the ViewModel, we can just start the recursive process.

        drawNextWinner(
            reward: reward, allRewards: allRewards, context: context,
            availableCandidates: reward.candidates)
    }

    private func drawNextWinner(
        reward: Reward, allRewards: [Reward], context: ModelContext,
        availableCandidates: [Candidate]
    ) {
        var currentAvailable = availableCandidates

        if reward.winners.count >= reward.numberOfWinners || currentAvailable.isEmpty {
            isDrawing = false
            spinningPlayer?.stop()
            spinningPlayer = nil
            finishPlayer = playSound(named: "finish.mp3")
            confettiBursts.append(UUID())
            return
        }

        let highlightDelay = 0.1
        let numberOfHighlights = Int(spinningDuration / highlightDelay)

        // Animation phase
        for i in 0..<numberOfHighlights {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * highlightDelay) {
                [weak self] in
                guard let self = self else { return }
                // Note: Modifying published property from background thread?
                // Dispatch is main.asyncAfter so it's on main thread.
                self.highlightedCandidate = self.randomDifferentElement(
                    from: currentAvailable,
                    excluding: self.highlightedCandidate
                )
            }
        }

        // Selection phase
        DispatchQueue.main.asyncAfter(deadline: .now() + spinningDuration) { [weak self] in
            guard let self = self else { return }

            guard let winner = currentAvailable.randomElement() else {
                self.isDrawing = false
                return
            }

            // Remove winner from local available list
            currentAvailable.removeAll { $0.id == winner.id }

            // UI Updates
            withAnimation(.spring()) {
                reward.winners.append(winner)
                self.highlightedCandidate = nil
                self.playTick()
            }

            // Logic: Remove from other rewards
            for otherReward in allRewards where otherReward.id != reward.id {
                otherReward.candidates.removeAll { $0.name == winner.name }
            }

            do {
                try context.save()
            } catch {
                print("Failed to save context: \(error)")
            }

            // Next iteration
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.drawNextWinner(
                    reward: reward, allRewards: allRewards, context: context,
                    availableCandidates: currentAvailable)
            }
        }
    }

    // MARK: - Helper Methods

    private func randomDifferentElement<T: Equatable>(from array: [T], excluding current: T?) -> T?
    {
        let filtered = array.filter { $0 != current }
        return filtered.randomElement() ?? array.randomElement()
    }

    private func playSound(named name: String, loop: Bool = false) -> AVAudioPlayer? {
        guard let url = Bundle.main.url(forResource: name, withExtension: nil) else {
            print("Audio file not found:", name)
            return nil
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = loop ? -1 : 0
            if name == "finish.mp3" {
                player.volume = 0.4
            } else {
                player.volume = 0.7
            }
            player.prepareToPlay()
            player.play()
            return player
        } catch {
            print("Failed to create AVAudioPlayer:", error.localizedDescription)
            return nil
        }
    }

    private func playTick() {
        if tickPlayer == nil {
            guard let url = Bundle.main.url(forResource: "tick.mp3", withExtension: nil) else {
                return
            }
            tickPlayer = try? AVAudioPlayer(contentsOf: url)
            tickPlayer?.volume = 0.5
            tickPlayer?.prepareToPlay()
        }
        tickPlayer?.currentTime = 0
        tickPlayer?.play()
    }

    func cleanUpConfetti(id: UUID) {
        confettiBursts.removeAll { $0 == id }
    }
}
