//
//  HealthKitService.swift
//  VitaSyncApp
//
//  Created by Manish Jawale on 19/03/26.
//

import HealthKit
import Foundation

@Observable
class HealthKitService {
    private let store = HKHealthStore()
    var isAuthorized = false
    
    // The data types we want to read
    private let readTypes: Set<HKObjectType> = [
        HKQuantityType(.stepCount),
        HKQuantityType(.heartRate),
        HKQuantityType(.heartRateVariabilitySDNN),
        HKQuantityType(.restingHeartRate),
        HKQuantityType(.activeEnergyBurned),
        HKCategoryType(.sleepAnalysis)
    ]
    
    // MARK: - Authorization
    
    func requestAuthorization() async throws {
        guard HKHealthStore.isHealthDataAvailable() else {
            throw HealthKitError.notAvailable
        }
        
        try await store.requestAuthorization(toShare: [], read: readTypes)
        isAuthorized = true
    }
    
    // MARK: - Steps
    
    func fetchTodaySteps() async -> Int {
        let type = HKQuantityType(.stepCount)
        let predicate = HKQuery.predicateForSamples(withStart: Calendar.current.startOfDay(for: Date()), end: Date()
        )
        let result = await fetchSum(type: type, predicate: predicate, unit: .count())
        return Int(result)
    }
    
    // MARK: - Resting Heart Rate
    
    func fetchRestingHeartRate() async -> Double {
        let type = HKQuantityType(.restingHeartRate)
        return await fetchMostRecent(type: type, unit: HKUnit(from: "count/min"))
    }
    
    // MARK: - Heart Rate Variability (HRV)
    
    func fetchHRV() async -> Double {
        let type = HKQuantityType(.heartRateVariabilitySDNN)
        return await fetchMostRecent(type: type, unit: .secondUnit(with: .milli))
    }
    
    // MARK: - Sleep
    
    func fetchLastNightSleep() async -> Double {
        let type = HKCategoryType(.sleepAnalysis)
        let now = Date()
        let yesterday = Calendar.current.date(byAdding: .hour, value: -24, to: now)!
        let predicate = HKQuery.predicateForSamples(withStart: yesterday, end: now)

        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: type,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: nil
            ) { _, samples, _ in
                guard let samples = samples as? [HKCategorySample] else {
                    continuation.resume(returning: 0)
                    return
                }

                let totalSeconds = samples.reduce(0.0) { result, sample in
                    let isAsleep = sample.value != HKCategoryValueSleepAnalysis.inBed.rawValue
                    let duration = sample.endDate.timeIntervalSince(sample.startDate)
                    return result + (isAsleep ? duration : 0)
                }

                continuation.resume(returning: totalSeconds / 3600)
            }
            self.store.execute(query)
        }
    }
    
    // MARK: - Private helpers
    
    private func fetchSum(type: HKQuantityType,
                          predicate: NSPredicate,
                          unit: HKUnit) async -> Double {
        await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: type,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum,
            ) { _, result, _ in
                continuation.resume(returning: result?.sumQuantity()?.doubleValue(for: unit) ?? 0)
            }
            self.store.execute(query)
        }
    }
    
    private func fetchMostRecent(type: HKQuantityType, unit: HKUnit) async -> Double {
        await withCheckedContinuation { continuation in
                let sort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
            let query = HKSampleQuery(
                sampleType: type,
                predicate: nil,
                limit: 1,
                sortDescriptors: [sort]
            ) { _, samples, _ in
                let value = (samples?.first as? HKQuantitySample)?
                    .quantity.doubleValue(for: unit) ?? 0
                continuation.resume(returning: value)
            }
            self.store.execute(query)
        }
    }
}

// MARK: Errors

enum HealthKitError: LocalizedError {
    case notAvailable
    
    var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "HealthKit is not available on this device."
        }
    }
}
