//
//  VitaSyncWidgetViews.swift
//  VitaSync
//
//  Created by Manish Jawale on 26/03/26.
//

import SwiftUI
import WidgetKit

// MARK: - Small widget (home screen)

struct SmallWidgetView: View {
    let entry: VitaSyncEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {

            // Header
            HStack(spacing: 5) {
                Image("AppIcon")
                    .resizable()
                    .frame(width: 16, height: 16)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                Text("VitaSync")
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
            }

            // Steps — primary metric
            VStack(alignment: .leading, spacing: 2) {
                Text("\(entry.data.steps.formatted())")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                Text("steps today")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Mini metrics row
            HStack(spacing: 8) {
                MiniMetric(value: "\(Int(entry.data.restingHR))", unit: "bpm")
                MiniMetric(value: "\(Int(entry.data.hrv))", unit: "ms")
                MiniMetric(
                    value: String(format: "%.1f", entry.data.sleepHours),
                    unit: "h"
                )
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
}

// MARK: - Medium widget (home screen)

struct MediumWidgetView: View {
    let entry: VitaSyncEntry

    var body: some View {
        HStack(spacing: 16) {

            // Left — insight
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 5) {
                    Image("AppIcon")
                        .resizable()
                        .frame(width: 14, height: 14)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                    Text("VitaSync insight")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                }
                Text(entry.data.insight)
                    .font(.caption)
                    .lineLimit(4)
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Divider()

            // Right — metrics
            VStack(alignment: .leading, spacing: 8) {
                MetricPill(
                    icon: "figure.walk",
                    value: "\(entry.data.steps.formatted())",
                    unit: "steps"
                )
                MetricPill(
                    icon: "heart.fill",
                    value: "\(Int(entry.data.restingHR))",
                    unit: "bpm"
                )
                MetricPill(
                    icon: "moon.fill",
                    value: String(format: "%.1f", entry.data.sleepHours),
                    unit: "h"
                )
            }
            .frame(width: 90)
        }
        .padding(14)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Lock screen rectangular widget

struct LockScreenRectView: View {
    let entry: VitaSyncEntry

    var body: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text("VitaSync")
                    .font(.caption2)
                    .fontWeight(.medium)
                Text(entry.data.insight)
                    .font(.caption2)
                    .lineLimit(2)
            }
            Spacer()
        }
        .padding(.horizontal, 4)
    }
}

// MARK: - Lock screen circular widget

struct LockScreenCircleView: View {
    let entry: VitaSyncEntry

    var body: some View {
        VStack(spacing: 2) {
            Image(systemName: "waveform.path.ecg")
                .font(.system(size: 14, weight: .medium))
            Text("\(entry.data.steps / 1000)k")
                .font(.caption2)
                .fontWeight(.medium)
        }
    }
}

// MARK: - Reusable subviews

struct MiniMetric: View {
    let value: String
    let unit: String

    var body: some View {
        VStack(spacing: 1) {
            Text(value)
                .font(.caption2)
                .fontWeight(.medium)
            Text(unit)
                .font(.system(size: 8))
                .foregroundStyle(.secondary)
        }
    }
}

struct MetricPill: View {
    let icon: String
    let value: String
    let unit: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.caption2)
                .fontWeight(.medium)
            Text(unit)
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
        }
    }
}


