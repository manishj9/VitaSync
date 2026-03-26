//
//  VitaSync.swift
//  VitaSync
//
//  Created by Manish Jawale on 19/03/26.
//

import SwiftUI
import SwiftData
import AppIntents

@main
struct VitaSync: App {
    
    init() {
            // Must be called here — before app finishes launching
            BackgroundTaskManager.shared.registerBackgroundTask()
        }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    // Schedule the first nightly refresh
                    BackgroundTaskManager.shared.scheduleNightlyRefresh()
                    // Donate intent so Siri suggests it
                    HealthStatusIntent.donate()
                }
        }
        .modelContainer(for: [HealthLog.self, FoodEntry.self])
    }
}

// Extension to make donation easy
extension AppIntent {
    static func donate() {
        Task {
            try? await Self().perform()
        }
    }
}
