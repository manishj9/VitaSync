//
//  Untitled.swift
//  VitaSyncApp
//
//  Created by Manish Jawale on 19/03/26.
//

import SwiftUI

extension Color {

    // Primary brand purple
    static let vitaPrimary      = Color(hex: "6B4FD8")

    // Lighter purple for dark mode
    static let vitaPrimaryLight = Color(hex: "9B7FF4")

    // Deep background purple
    static let vitaDark         = Color(hex: "0F0E1A")

    // Mint green accent — the live dot
    static let vitaMint         = Color(hex: "A8F0C6")

    // Soft purple tint for card backgrounds
    static let vitaTint         = Color(hex: "6B4FD8").opacity(0.08)

    // Hex initializer — lives here, used by all static colors above
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8)  & 0xFF) / 255
        let b = Double( int        & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
