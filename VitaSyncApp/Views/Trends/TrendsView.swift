//
//  TrendsView.swift
//  VitaSyncApp
//
//  Created by Manish Jawale on 21/03/26.
//

import SwiftUI
import Charts

struct TrendsView: View {
    
    @State private var viewModel = TrendsViewModel()
    @State private var selectedRange = 7
    
    private let ranges = [7, 14, 30]
    
    var body: some View {
        
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // Range selector
                HStack(spacing: 8) {
                    ForEach(ranges, id: \.self) { range in
                        Button {
                            selectedRange = range
                            viewModel.selectedRange = range
                            
                        } label: {
                            Text("\(range)d")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(
                                    selectedRange == range ? .white : Color.vitaPrimary
                                )
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    selectedRange == range ?
                                    Color.vitaPrimary : Color.vitaPrimary.opacity(0.1)
                                )
                                .clipShape(Capsule())
                        }
                    }
                    Spacer()
                }
                
                // Summary Cards Row
                HStack(spacing: 10) {
                    SummaryStatCard(
                        label: "Avg Steps",
                        value: Int(viewModel.average(of: viewModel.stepsData)).formatted(), unit: "steps"
                    )
                    SummaryStatCard(
                        label: "Avg Sleep",
                        value: String(format: "%.1f", viewModel.average(of: viewModel.sleepData)),
                        unit: "h"
                    )
                    SummaryStatCard(
                        label: "Avg HRV",
                        value: String(Int(viewModel.average(of: viewModel.hrvData))),
                        unit: "ms"
                    )
                }
                
                // Charts
                MetricChartCard(
                    title: "Steps",
                    unit: "steps",
                    data: viewModel.stepsData,
                    color: .vitaPrimary,
                    higherIsBetter: true
                )
                
                MetricChartCard(
                    title: "Resting heart rate",
                    unit: "bpm",
                    data: viewModel.heartRateData,
                    color: Color(hex: "E05C5C"),
                    higherIsBetter: false
                )
                
                MetricChartCard(
                    title: "HRV",
                    unit: "ms",
                    data: viewModel.hrvData,
                    color: .vitaMint,
                    higherIsBetter: true
                )
                
                MetricChartCard(
                    title: "Sleep",
                    unit: "h",
                    data: viewModel.sleepData,
                    color: Color(hex: "9B7FF4"),
                    higherIsBetter: true
                )
                
                Text("Data shown as 7-day rolling averages")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 8)
            }
            .padding()
        }
        .navigationTitle("Trends")
        .navigationBarTitleDisplayMode(.large)
        .onAppear { viewModel.loadData() }
    }
}

// MARK: - Summary stat card

struct SummaryStatCard: View {
    let label: String
    let value: String
    let unit: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption2)
                .foregroundStyle(.tertiary)
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(unit)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.vitaPrimary.opacity(0.1), lineWidth: 0.5)
        )
    }
}
