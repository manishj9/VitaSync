//
//  MetricCardView.swift
//  VitaSyncApp
//
//  Created by Manish Jawale on 19/03/26.
//

import SwiftUI

struct MetricCardView: View {
    let label: String
    let value: String
    let unit: String
    let trend: String
    let trendUp: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.tertiary)
            HStack(alignment: .lastTextBaseline, spacing: 3) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.medium)
                Text(unit)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Text(trend)
                .font(.caption)
                .foregroundStyle(trendUp ? .vitaMint : Color(hex: "#E05C5C"))
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(.separator, lineWidth: 0.5))
        
    }
}
