//
//  VitaSyncIntent.swift
//  VitaSync
//
//  Created by Manish Jawale on 26/03/26.
//

import AppIntents
import SwiftUI

struct HealthStatusIntent: AppIntent {

    static var title: LocalizedStringResource = "Get my health status"
    static var description = IntentDescription(
        "Get your current VitaSync health summary.",
        categoryName: "Health"
    )

    // What Siri says when user asks

    func perform() async throws -> some ProvidesDialog & ShowsSnippetView {
        let data = WidgetDataStore.shared.load()
        let dialog = buildDialog(data: data)
        let view = HealthSnippetView(data: data)
        return .result(dialog: IntentDialog(stringLiteral: dialog), view: view)
    }

    private func buildDialog(data: WidgetHealthData) -> String {
        var parts: [String] = []

        if data.steps > 0 {
            parts.append("\(data.steps.formatted()) steps today")
        }
        if data.sleepHours > 0 {
            parts.append(String(format: "%.1f hours of sleep", data.sleepHours))
        }
        if data.hrv > 0 {
            parts.append("HRV of \(Int(data.hrv)) milliseconds")
        }

        if parts.isEmpty {
            return "Open VitaSync to sync your health data first."
        }

        return "Here's your VitaSync summary: \(parts.joined(separator: ", "))."
    }
}

// MARK: - Siri snippet view

struct HealthSnippetView: View {
    let data: WidgetHealthData

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            HStack(spacing: 8) {
                Image("AppIcon")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                Text("VitaSync")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }

            HStack(spacing: 16) {
                SnippetMetric(value: data.steps.formatted(), unit: "steps",
                              icon: "figure.walk")
                SnippetMetric(value: String(format: "%.1f", data.sleepHours),
                              unit: "h sleep", icon: "moon.fill")
                SnippetMetric(value: "\(Int(data.hrv))", unit: "ms HRV",
                              icon: "waveform.path.ecg")
            }

            Text(data.insight)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .padding(12)
    }
}

struct SnippetMetric: View {
    let value: String
    let unit: String
    let icon: String

    var body: some View {
        VStack(spacing: 3) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(Color.vitaPrimary)
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
            Text(unit)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}
