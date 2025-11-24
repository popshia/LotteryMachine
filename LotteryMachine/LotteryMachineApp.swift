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
            // This error typically happens when the model schema changes during development.
            // A simple yet destructive fix is to delete the old database file.
            // WARNING: This will delete all user data in the app.
            let url = modelConfiguration.url
            print("Failed to load ModelContainer. Deleting old database at \(url.path)...")
            try? FileManager.default.removeItem(at: url)

            // Try creating the container again after deleting the old file.
            do {
                return try ModelContainer(for: schema, configurations: [modelConfiguration])
            } catch {
                fatalError("Could not create ModelContainer after deleting old file: \(error)")
            }
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
