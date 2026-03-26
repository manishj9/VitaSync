//
//  Secrets.swift
//  VitaSyncApp
//
//  Created by Manish Jawale on 20/03/26.
//

import Foundation

enum Secrets {
    static var geminiApiKey: String {
        guard
            let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
            let dict = NSDictionary(contentsOfFile: path),
            let key = dict["GEMINI_API_KEY"] as? String
        else {
            fatalError("Secrets.plist missing or GEMINI_API_KEY not set.")
        }
        return key
            
    }
}
