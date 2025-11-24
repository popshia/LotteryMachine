//
//  LotteryMachineApp.swift
//  LotteryMachine
//
//  Created by Noah on 2025/11/21.
//

import SwiftData
import SwiftUI

@main
struct LotteryMachineApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Reward.self, Candidate.self])
        #if os(macOS)
            Settings {
                SettingsView()
            }
        #endif
    }
}
