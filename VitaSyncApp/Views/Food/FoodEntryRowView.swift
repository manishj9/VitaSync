//
//  FoodEntryRowView.swift
//  VitaSyncApp
//
//  Created by Manish Jawale on 21/03/26.
//


import SwiftUI

struct FoodEntryRowView: View {
    let entry: FoodEntry

    var body: some View {
        HStack(spacing: 12) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.vitaPrimary.opacity(0.1))
                    .frame(width: 40, height: 40)
                Image(systemName: "fork.knife")
                    .font(.system(size: 16))
                    .foregroundStyle(Color.vitaPrimary)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(entry.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(entry.date.formatted(date: .omitted, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("\(entry.estimatedCalories)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.vitaMint)
                Text("kcal")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(12)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.vitaPrimary.opacity(0.1), lineWidth: 0.5)
        )
    }
}


