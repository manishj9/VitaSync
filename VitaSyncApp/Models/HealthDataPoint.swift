//
//  HealthDataPoint.swift
//  VitaSyncApp
//
//  Created by Manish Jawale on 22/03/26.
//

import Foundation

struct HealthDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
    let label: String
    
    var shortDate: String {
        date.formatted(.dateTime.weekday(.abbreviated))
    }
    
    var dayNumber: String {
        date.formatted(.dateTime.day())
    }
}

// MARK: - Sample data generator for Simulator

struct HealthSampleData {
    
    static func steps(for days: Int = 7) -> [HealthDataPoint] {
        generate(days: days, base: 7500, variance: 3000, label: "steps")
    }
    
    static func heartRate(for days: Int = 7) -> [HealthDataPoint] {
        generate(days: days, base: 65, variance: 10, label: "bpm")
    }
    
    static func hrv(for days: Int = 7) -> [HealthDataPoint] {
        generate(days: days, base: 48, variance: 15, label: "ms")
    }
    
    static func sleep(for days: Int = 7) -> [HealthDataPoint] {
            generate(days: days, base: 7.2, variance: 1.5, label: "h")
        }
    
    private static func generate(
            days: Int,
            base: Double,
            variance: Double,
            label: String
        ) -> [HealthDataPoint] {
            (0..<days).map { i in
                let date = Calendar.current.date(
                    byAdding: .day,
                    value: -(days - 1 - i),
                    to: Date()
                ) ?? Date()
                let value = max(0, base + Double.random(in: -variance...variance))
                return HealthDataPoint(date: date, value: value, label: label)
            }
        }
}

