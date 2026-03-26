//
//  HomeViewModel.swift
//  VitaSyncApp
//
//  Created by Manish Jawale on 19/03/26.
//

import Foundation
import SwiftData
import WidgetKit

@Observable
class HomeViewModel {
    
    // Health Data
    var steps: Int = 0
    var restingHR: Double = 0
    var hrv: Double = 0
    var sleepHours: Double = 0
    
    // Insight
    var insight: String = "Fetching your health data..."
    var isLoadingInsight = false
    
    // State
    var isLoading = false
    var errorMessage: String?
    
    private let healthKit = HealthKitService()
    private let gemini = GeminiService()
    
    // MARK: Authorization (Entry Point)
    
    func requestPermissions() async {
        
        // Show last night's saved insight immediately
                loadSavedInsight()
        
        do {
            try await healthKit.requestAuthorization()
            await fetchAll()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Load most recent insight from SwiftData

        func loadSavedInsight() {
            let config = ModelConfiguration(isStoredInMemoryOnly: false)
            guard let container = try? ModelContainer(
                for: HealthLog.self,
                configurations: config
            ) else { return }

            let context = container.mainContext
            let descriptor = FetchDescriptor<HealthLog>(
                sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
            )

            if let latest = try? context.fetch(descriptor).first,
               let saved = latest.aiInsight {
                insight      = saved
                steps        = latest.steps
                restingHR    = latest.restingHR
                hrv          = latest.hrv
                sleepHours   = latest.sleepHours
            }
        }
    
    // MARK: Fetch Health Data then generate Insight
    
    func fetchAll() async {
        
    #if targetEnvironment(simulator)
    steps      = 7_843
    restingHR  = 62
    hrv        = 48
    sleepHours = 7.2
    isLoading  = false
    await generateInsight()
    saveToWidgetStore()
    return
    #endif

    isLoading = true
    async let s  = healthKit.fetchTodaySteps()
    async let hr = healthKit.fetchRestingHeartRate()
    async let h  = healthKit.fetchHRV()
    async let sl = healthKit.fetchLastNightSleep()

    steps      = await s
    restingHR  = await hr
    hrv        = await h
    sleepHours = await sl
    isLoading  = false

    await generateInsight()
    saveToWidgetStore()
        
    }
    
    // MARK: - Save to widget store

    private func saveToWidgetStore() {
        let data = WidgetHealthData(
            steps:       steps,
            restingHR:   restingHR,
            hrv:         hrv,
            sleepHours:  sleepHours,
            insight:     insight,
            lastUpdated: Date()
        )
        WidgetDataStore.shared.save(data)

        // Tell WidgetKit to refresh
        #if canImport(WidgetKit)
        WidgetCenter.shared.reloadAllTimelines()
        #endif
    }
    
    // MARK: Generate Insight
    
    func generateInsight() async {
        isLoadingInsight = true

        // Stable detached task prevents cancellation during view re-renders
        let result = await Task.detached(priority: .userInitiated) { [weak self] in
            guard let self else { return "Unable to generate insight." }
            return await self.gemini.generateInsight(
                steps:     self.steps,
                restingHR: self.restingHR,
                hrv:       self.hrv,
                sleepHours: self.sleepHours
            )
        }.value

        insight = result
        isLoadingInsight = false
    }

    
    // MARK: Display Helpers
    
    var stepDisplay: String {
        steps == 0 ? "--" : steps.formatted()
    }
    
    var heartRateDisplay: String {
        restingHR == 0 ? "--" : String(Int(restingHR))
    }
    
    var hrvDisplay: String {
        hrv == 0 ? "--" : String(Int(hrv))
    }
    
    var sleepDisplay: String {
        sleepHours == 0 ? "--" : String(format: "%.1f", sleepHours)
    }
}
