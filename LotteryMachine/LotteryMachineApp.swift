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
            CategoryOrderPreference.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    // MARK: - Body

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.light)
        }
        .modelContainer(sharedModelContainer)
    }
}
