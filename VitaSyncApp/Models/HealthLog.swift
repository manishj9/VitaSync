//
//  HealthLog.swift
//  VitaSyncApp
//
//  Created by Manish Jawale on 19/03/26.
//

import SwiftData
import Foundation

@Model
class HealthLog {
    var date: Date
    var steps: Int
    var restingHR: Double
    var hrv: Double
    var sleepHours : Double
    var aiInsight: String?
    var createdAt: Date
    
    init(date: Date, steps: Int = 0,
         restingHR: Double = 0,
         hrv: Double = 0,
         sleepHours: Double = 0) {
        self.date = date
        self.steps = steps
        self.restingHR = restingHR
        self.hrv = hrv
        self.sleepHours = sleepHours
        self.createdAt = Date()
    }
    
}

