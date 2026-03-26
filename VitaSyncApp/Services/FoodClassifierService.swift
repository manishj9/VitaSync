//
//  FoodClassifierService.swift
//  VitaSyncApp
//
//  Created by Manish Jawale on 21/03/26.
//

import Vision
import UIKit
import Foundation

class FoodClassifierService {
    // MARK: - Classify Image using Vision
    
    func classify(image: UIImage) async -> FoodClassificationResult {
        guard let cgImage = image.cgImage else {
            return FoodClassificationResult(name: "Unknown food", confidence: 0, calories: 0)
        }
        
        return await withCheckedContinuation { continuation in
            let request = VNClassifyImageRequest { request, error in
                guard error == nil,
                      let results = request.results as? [VNClassificationObservation],
                      let top = results.first
                        else {
                    continuation.resume(returning: FoodClassificationResult(
                        name: "Could not identify",
                        confidence: 0,
                        calories: 0
                    ))
                return
                }
                
                let foodName = self.cleanLabel(top.identifier)
                let confidence = Double(top.confidence)
                let calories = self.estimateCalories(for: top.identifier)
                
                continuation.resume(returning: FoodClassificationResult(
                    name: foodName,
                    confidence: confidence,
                    calories: calories
                ))
        }
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        try? handler.perform([request])
    }
}

// MARK: Clean Up Vision Label

private func cleanLabel(_ identifier: String) -> String {
    identifier
        .replacingOccurrences(of: "_", with: " ")
        .split(separator: ",")
        .first
        .map(String.init)?
        .trimmingCharacters(in: .whitespaces)
        .capitalized ?? identifier.capitalized
    }

// MARK: Calorie estimates for comman foods

private func estimateCalories(for identifier: String) -> Int {
    let label = identifier.lowercased()
    
    let calorieMap: [String: Int] = [
               "pizza": 285,
               "burger": 354,
               "sandwich": 290,
               "salad": 120,
               "pasta": 320,
               "rice": 206,
               "chicken": 239,
               "steak": 271,
               "fish": 180,
               "sushi": 200,
               "ramen": 436,
               "noodle": 220,
               "bread": 265,
               "egg": 155,
               "pancake": 227,
               "waffle": 291,
               "cereal": 150,
               "oatmeal": 166,
               "yogurt": 100,
               "fruit": 80,
               "apple": 95,
               "banana": 105,
               "orange": 62,
               "coffee": 5,
               "juice": 112,
               "smoothie": 180,
               "ice_cream": 273,
               "cake": 347,
               "cookie": 148,
               "chocolate": 546,
               "soup": 75,
               "taco": 226,
               "burrito": 395,
               "curry": 303,
               "dal": 198,
               "idli": 58,
               "dosa": 133,
               "biryani": 290,
               "samosa": 262,
               "naan": 262
           ]
    
    for (key, cal) in calorieMap {
        if label.contains(key) { return cal }
    }
    
    return 250 // Default estimate for unknown foods
    
    }
}

// MARK: Result model
 
struct FoodClassificationResult {
    let name: String
    let confidence: Double
    let calories: Int
    
    var confidencePercent: String {
        "\(Int(confidence * 100))% match"
    }
    
    var isReliable: Bool {
        confidence > 0.1
    }
}
