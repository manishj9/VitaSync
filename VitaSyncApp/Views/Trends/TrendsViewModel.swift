//
//  TrendsViewModel.swift
//  VitaSyncApp
//
//  Created by Manish Jawale on 23/03/26.
//

import Foundation

@Observable
class TrendsViewModel {
    
    var stepsData: [HealthDataPoint] = []
    var heartRateData: [HealthDataPoint] = []
    var hrvData: [HealthDataPoint] = []
    var sleepData: [HealthDataPoint] = []
    var isLoading = false
    
    var selectedRange: Int = 7 {
        didSet { loadData() }
    }
    
    // MARK: - Load Data
    
    func loadData() {
        isLoading = true
        
        #if targetEnvironment(simulator)
        loadSimulatorData()
        #else
        Task { await loadRealData() }
        #endif
        
        isLoading = false
    }
    
    private func loadSimulatorData() {
        stepsData = HealthSampleData.steps(for: selectedRange)
        heartRateData = HealthSampleData.heartRate(for: selectedRange)
        hrvData = HealthSampleData.hrv(for: selectedRange)
        sleepData = HealthSampleData.sleep(for: selectedRange)
        
    }
    
    private func loadRealData() async {
        let service = HealthKitService()
        stepsData = HealthSampleData.steps(for: selectedRange)
        heartRateData = HealthSampleData.heartRate(for: selectedRange)
        hrvData = HealthSampleData.hrv(for: selectedRange)
        sleepData = HealthSampleData.sleep(for: selectedRange)
    }
    
    // MARK: Summary Stats
    
    func average(of data: [HealthDataPoint]) -> Double {
        guard !data.isEmpty else { return 0 }
        return data.reduce(0) { $0 + $1.value } / Double(data.count)
    }
    
    func trend(of data: [HealthDataPoint]) -> Double {
        guard data.count >= 2 else { return 0 }
        let first = data.prefix(data.count / 2).reduce(0) { $0 + $1.value } / Double(data.count / 2)
        let last = data.suffix(data.count / 2).reduce(0) { $0 + $1.value } / Double(data.count / 2)
        return ((last - first ) / first) * 100
    }
    
    func trendIsUp(_ data: [HealthDataPoint], higherIsBetter: Bool) -> Bool {
        let t = trend(of: data)
        return higherIsBetter ? t >= 0 : t <= 0
    }
}

