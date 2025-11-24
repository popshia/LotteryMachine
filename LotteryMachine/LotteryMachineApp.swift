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
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Reward.self,
            Candidate.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)

        #if os(macOS)
        Settings {
            SettingsView()
                .modelContainer(sharedModelContainer)
        }
        #endif
    }
}
