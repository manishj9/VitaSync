//
//  FoodLogView.swift
//  VitaSyncApp
//
//  Created by Manish Jawale on 21/03/26.
//

import SwiftUI
import SwiftData

struct FoodLogView: View {

    @Environment(\.modelContext) private var modelContext
    @Query(sort: \FoodEntry.date, order: .reverse) private var entries: [FoodEntry]
    @State private var showScanner = false

    private var totalCaloriesToday: Int {
        let today = Calendar.current.startOfDay(for: Date())
        return entries
            .filter { $0.date >= today }
            .reduce(0) { $0 + $1.estimatedCalories }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                CalorieSummaryCard(totalCalories: totalCaloriesToday)
                ScanMealButton(showScanner: $showScanner)
                FoodEntryList(entries: entries)
            }
            .padding()
        }
        .navigationTitle("Food log")
        .navigationBarTitleDisplayMode(.large)
        .fullScreenCover(isPresented: $showScanner) {
            FoodScannerView()
        }
    }
}

// MARK: - Calorie summary card

private struct CalorieSummaryCard: View {
    let totalCalories: Int

    private var progress: CGFloat {
        min(CGFloat(totalCalories) / 2000.0, 1.0)
    }

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Today's calories")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text("\(totalCalories)")
                        .font(.title)
                        .fontWeight(.medium)
                        .foregroundStyle(Color.vitaPrimary)
                    Text("kcal")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            CalorieRing(progress: progress, totalCalories: totalCalories)
        }
        .padding(16)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.vitaPrimary.opacity(0.1), lineWidth: 0.5)
        )
    }
}

// MARK: - Calorie ring

private struct CalorieRing: View {
    let progress: CGFloat
    let totalCalories: Int

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.vitaPrimary.opacity(0.12), lineWidth: 8)
                .frame(width: 64, height: 64)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    Color.vitaPrimary,
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .frame(width: 64, height: 64)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.6), value: totalCalories)
            Text("\(Int(progress * 100))%")
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundStyle(Color.vitaPrimary)
        }
    }
}

// MARK: - Scan button

private struct ScanMealButton: View {
    @Binding var showScanner: Bool

    var body: some View {
        Button {
            showScanner = true
        } label: {
            HStack {
                Image(systemName: "camera.fill")
                Text("Scan a meal")
                    .fontWeight(.medium)
            }
            .font(.subheadline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.vitaPrimary)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }
}

// MARK: - Food entry list

private struct FoodEntryList: View {
    let entries: [FoodEntry]

    var body: some View {
        if entries.isEmpty {
            EmptyFoodState()
        } else {
            VStack(spacing: 8) {
                ForEach(entries) { entry in
                    FoodEntryRowView(entry: entry)
                }
            }
        }
    }
}

// MARK: - Empty state

private struct EmptyFoodState: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "fork.knife.circle")
                .font(.system(size: 48))
                .foregroundStyle(Color.vitaPrimary.opacity(0.3))
            Text("No meals logged yet")
                .font(.headline)
                .foregroundStyle(.secondary)
            Text("Scan your first meal above")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}
