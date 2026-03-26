//
//  MetricChartCard.swift
//  VitaSyncApp
//
//  Created by Manish Jawale on 23/03/26.
//

import SwiftUI
import Charts

struct MetricChartCard: View {
    
    let title: String
    let unit: String
    let data: [HealthDataPoint]
    let color: Color
    let higherIsBetter: Bool
    
    @State private var animateChart = false
    
    private var average: Double {
        guard !data.isEmpty else { return 0 }
        return data.reduce(0) { $0 + $1.value } / Double(data.count)
    }
    
    private var trendPercent: Double {
        guard data.count >= 2 else { return 0 }
        let first = data.prefix(data.count / 2).reduce(0) {$0 + $1.value } / Double(data.count / 2)
        let last = data.suffix(data.count / 2).reduce(0) {$0 + $1.value } / Double(data.count / 2)
        return ((last - first) / first) * 100
    }
    
    private var trendIsPositive: Bool {
        higherIsBetter ? trendPercent >= 0 : trendPercent <= 0
    }
    
    private var trendLabel: String {
        let abs = abs(trendPercent)
        let dir = trendPercent >= 0 ? "+" : "-"
        return "\(dir)\(Int(abs))% vs prior period"
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            
            // Header
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                    
                    HStack(alignment: .lastTextBaseline, spacing: 4) {
                        Text(formatAverage())
                            .font(.title2)
                            .fontWeight(.medium)
                        Text(unit)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
                
                // Trend Badge
                HStack(spacing: 4) {
                    Image(systemName: trendIsPositive ? "arrow.up.right" : "arrow.down.right")
                        .font(.system(size: 10, weight: .bold))
                    Text(trendLabel)
                        .font(.caption2)
                        .fontWeight(.medium)
                }
                .foregroundStyle(trendIsPositive ? Color.vitaMint : Color(hex: "E05C5C"))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background((trendIsPositive ? Color.vitaMint : Color(hex: "E05C5C")) .opacity(0.12)
                )
                .clipShape(Capsule())
            }
            
            // Chart
            Chart(data) { point in
                AreaMark(
                    x: .value("Day", point.date),
                    y: .value(title, animateChart ? point.value : 0)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [color.opacity(0.3), color.opacity(0.0)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .interpolationMethod(.catmullRom)
                
                LineMark(
                    x: .value("Day", point.date),
                    y: .value(title, animateChart ? point.value : 0)
                )
                .foregroundStyle(color)
                .lineStyle(StrokeStyle(lineWidth: 2.5))
                .interpolationMethod(.catmullRom)
        
                PointMark(
                    x: .value("Day", point.date),
                    y: .value(title, animateChart ? point.value : 0)
                )
                .foregroundStyle(color)
                .symbolSize(30)
            }
            .chartXAxis {
                AxisMarks(position: .leading) { value in
                    AxisValueLabel()
                        .font(.caption2)
                }
            }
            .frame(height: 140)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.8)) {
                    animateChart = true
                }
            }
        }
        .padding(16)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.vitaPrimary.opacity(0.1), lineWidth: 0.5)
        )
    }
    
    private func formatAverage() -> String {
            if unit == "h" {
                return String(format: "%.1f", average)
            } else if unit == "steps" {
                return Int(average).formatted()
            } else {
                return String(Int(average))
            }
        }
    }
