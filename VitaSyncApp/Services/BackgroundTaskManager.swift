//
//  BackgroundTaskManager.swift
//  VitaSyncApp
//
//  Created by Manish Jawale on 20/03/26.
//

import BackgroundTasks
import SwiftData
import Foundation

class BackgroundTaskManager {
    static let shared = BackgroundTaskManager()
    static let refreshTaskID = "com.manishjawale.VitaSync.refresh"
    
    private init() {}
    
    // MARK: - Register task handler
    // Call this once at app launch — before the app finishes launching
    
    func registerBackgroundTask(){
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: Self.refreshTaskID,
            using: nil,
        ) { task in
            guard let processingTask = task as? BGProcessingTask else { return }
                    self.handleRefreshTask(processingTask)
        }
    }
    
    // MARK: Schedule Next Refresh
    
    func scheduleNightlyRefresh(){
        let request = BGProcessingTaskRequest(
            identifier: Self.refreshTaskID
        )
        
        // Run after 2am
        request.earliestBeginDate = nextRefreshDate()
        
        // Require network for Gemini API call
        request.requiresNetworkConnectivity = true
        
        // Don't require external power (workon battery)
        request.requiresExternalPower = false
        
        do {
            try BGTaskScheduler.shared.submit(request)
            print("✅ Background refresh scheduled for \(nextRefreshDate())")
        } catch {
            print("🔴 Failed to schedule background task: \(error)")
        }
    }
    
    // MARK: - Handle the task when iOS wakes the app
    
    private func handleRefreshTask(_ task: BGProcessingTask) {
        // Schedule the NEXT refresh immediately
        scheduleNightlyRefresh()
        
        // Create a Task so we can cancel it if iOS needs memory back
        let refreshTask = Task {
            do {
                try await performRefresh()
                task.setTaskCompleted(success: true)
                print("✅ Background refresh completed successfully")
            } catch {
                task.setTaskCompleted(success: false)
                print("🔴 Background refresh failed: \(error)")
            }
        }
        
        // If iOS cancels us, cancel our work too
        task.expirationHandler = {
            refreshTask.cancel()
        }
    }
    
    // MARK: - The actual refresh work
    
    private func performRefresh() async throws {
        let healthKit = HealthKitService()
        let gemini    = GeminiService()
        
        // Fetch all health data in parallel
        async let steps      = healthKit.fetchTodaySteps()
        async let restingHR  = healthKit.fetchRestingHeartRate()
        async let hrv        = healthKit.fetchHRV()
        async let sleepHours = healthKit.fetchLastNightSleep()
        
        let s  = await steps
        let hr = await restingHR
        let h  = await hrv
        let sl = await sleepHours
        
        // Generate fresh Gemini insight
        let insight = await gemini.generateInsight(
            steps:      s,
            restingHR:  hr,
            hrv:        h,
            sleepHours: sl
        )
        
        // Save to SwiftData so HomeView shows it on next open
        await saveInsight(
            insight:    insight,
            steps:      s,
            restingHR:  hr,
            hrv:        h,
            sleepHours: sl
        )
    }
 // MARK: - Save result to SwiftData
    
    @MainActor
    private func saveInsight(
        insight:    String,
        steps:      Int,
        restingHR:  Double,
        hrv:        Double,
        sleepHours: Double
    ) async {
        let config = ModelConfiguration(isStoredInMemoryOnly: false)
        guard let container = try? ModelContainer(
            for: HealthLog.self,
            configurations: config
        ) else { return }
        
        let context = container.mainContext
        let log = HealthLog(
            date:       Date(),
            steps:      steps,
            restingHR:  restingHR,
            hrv:        hrv,
            sleepHours: sleepHours
        )
        log.aiInsight = insight
        context.insert(log)
        try? context.save()
        print("✅ Saved insight to SwiftData: \(insight.prefix(60))...")
    }
    
    // MARK: - Helper: next 2am

        private func nextRefreshDate() -> Date {
            let calendar = Calendar.current
            var components = calendar.dateComponents([.year, .month, .day], from: Date())
            components.hour   = 2
            components.minute = 0

            guard let tonight2am = calendar.date(from: components) else {
                return Date().addingTimeInterval(6 * 3600)
            }

            // If 2am already passed today, schedule for tomorrow
            if tonight2am < Date() {
                return calendar.date(byAdding: .day, value: 1, to: tonight2am)
                    ?? Date().addingTimeInterval(6 * 3600)
            }
            return tonight2am
        }
    }
    
    

