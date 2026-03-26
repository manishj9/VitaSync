//
//  FoodEntry.swift
//  VitaSyncApp
//
//  Created by Manish Jawale on 19/03/26.
//

import SwiftData
import Foundation

@Model
class FoodEntry {
    var date: Date
    var name: String
    var estimatedCalories: Int
    var note: String?
    
    init(date: Date, name: String, estimatedCalories: Int) {
        self.date = date
        self.name = name
        self.estimatedCalories = estimatedCalories
    }
}
