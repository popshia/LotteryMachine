//
//  LotteryMachineApp.swift
//  LotteryMachine
//
//  Created by Noah on 2025/11/21.
//

import SwiftUI

@main
struct LotteryMachineApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        #if os(macOS)
            Settings {
                SettingsView()
            }
        #endif
    }
}
