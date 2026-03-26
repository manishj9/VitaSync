//
//  WidgetDataStore.swift
//  VitaSync
//
//  Created by Manish Jawale on 26/03/26.
//

import Foundation

struct WidgetHealthData: Codable {
    var steps: Int
    var restingHR: Double
    var hrv: Double
    var sleepHours: Double
    var insight: String
    var lastUpdated: Date

    static var empty: WidgetHealthData {
        WidgetHealthData(
            steps: 0,
            restingHR: 0,
            hrv: 0,
            sleepHours: 0,
            insight: "Open VitaSync to generate your daily insight.",
            lastUpdated: Date()
        )
    }
}

class WidgetDataStore {

    static let shared = WidgetDataStore()
    private let suiteName = "group.com.manishjawale.VitaSync"
    private let key = "vitasync.widget.healthdata"

    private init() {}

    func save(_ data: WidgetHealthData) {
        guard let defaults = UserDefaults(suiteName: suiteName),
              let encoded = try? JSONEncoder().encode(data)
        else { return }
        defaults.set(encoded, forKey: key)
    }

    func load() -> WidgetHealthData {
        guard let defaults = UserDefaults(suiteName: suiteName),
              let data = defaults.data(forKey: key),
              let decoded = try? JSONDecoder().decode(WidgetHealthData.self, from: data)
        else { return .empty }
        return decoded
    }
}
