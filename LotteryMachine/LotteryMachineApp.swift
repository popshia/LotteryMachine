//
//  LotteryMachineApp.swift
//  LotteryMachine
//
//  Created by Noah on 2025/11/21.
//

import SwiftData
import SwiftUI

/// The main entry point of the Lottery Machine app.
@main
struct LotteryMachineApp: App {
    // MARK: - Properties

    /// The shared model container for SwiftData, configured for the `Reward` and `Candidate` models.
    ///
    /// This container is responsible for loading and managing the app's data.
    /// It includes error handling to delete and recreate the database if the schema changes,
    /// which is useful during development but will result in data loss.
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

    // MARK: - Body

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.light)
        }
        .modelContainer(sharedModelContainer)

        #if os(macOS)
            Settings {
                SettingsView()
                    .preferredColorScheme(.light)
                    .modelContainer(sharedModelContainer)
            }
        #endif
    }
}
