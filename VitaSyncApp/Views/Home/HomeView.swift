//
//  HomeView.swift
//  VitaSyncApp
//
//  Created by Manish Jawale on 19/03/26.
//

import SwiftUI
import _SwiftData_SwiftUI

struct HomeView: View {
    
    
    @State private var viewModel = HomeViewModel()
    @State private var showScanner = false
    @Query(sort: \FoodEntry.date, order: .reverse) private var foodEntries: [FoodEntry]
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        
        switch hour {
        case 5..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        default: return "Good Evening"
        }
    }
    
    @AppStorage("userName") private var userName = "there"
    
    // Static for now — replaced with real name from onboarding in Week 8
//        private let userName = "Manish"

//    // Static insight — replaced with LLM-generated text in Week 3
//        private let insight = "Your HRV jumped 14% last night and you got 7.8h of deep sleep — your body is well-recovered. Try a strength session today."
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                //Header
                VStack(alignment: .leading, spacing: 4) {
                    HStack{
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(greeting), \(userName)")
                                .font(.title2)
                                .fontWeight(.medium)
                            Text(Date.now.formatted(date: .complete, time: .omitted))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        // VitaSync logo mark
                        ZStack(alignment: .topTrailing) {
                            Image("VitaSyncIcon")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 44, height: 44)
                                .clipShape(RoundedRectangle(cornerRadius: 20))

                        }
                    }
                }
                
                // AI Insight Card
                InsightCardView(
                    text: viewModel.insight,
                    isLoading: viewModel.isLoadingInsight
                )
                
                // Metrics Grid
                Text("Today's Metrics")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                
                if viewModel.isLoading {
                    HStack {
                        Spacer()
                        ProgressView()
                            .tint(Color.vitaPrimary)
                        Spacer()
                    }
                    .padding(.vertical, 20)
                } else {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        MetricCardView(
                            label: "Steps",
                            value: viewModel.stepDisplay,
                            unit: "steps",
                            trend: "today",
                            trendUp: viewModel.steps > 5000)
                        
                        MetricCardView(
                            label: "Resting HR",
                            value: viewModel.heartRateDisplay,
                            unit: "bpm",
                            trend: "resting",
                            trendUp: viewModel.restingHR < 70)
                        
                        MetricCardView(
                            label: "Sleep",
                            value: viewModel.sleepDisplay,
                            unit: "h",
                            trend: "last night",
                            trendUp: viewModel.sleepHours >= 7)
                        
                        MetricCardView(
                            label: "HRV",
                            value: viewModel.hrvDisplay,
                            unit: "ms",
                            trend: "latest",
                            trendUp: viewModel.hrv >= 40
                        )
                    }
                }
                
                // Error state
                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .padding(.top, 4)
                }
                
                // Food log section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Food log")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Button {
                            showScanner = true
                        } label: {
                            HStack(spacing: 5) {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 12))
                                Text("Scan meal")
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            .foregroundStyle(Color.vitaPrimary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.vitaPrimary.opacity(0.1))
                            .clipShape(Capsule())
                        }
                    }

                    if foodEntries.isEmpty {
                        HStack {
                            Spacer()
                            VStack(spacing: 8) {
                                Image(systemName: "fork.knife")
                                    .font(.system(size: 28))
                                    .foregroundStyle(.tertiary)
                                Text("No meals logged yet")
                                    .font(.subheadline)
                                    .foregroundStyle(.tertiary)
                                Text("Tap 'Scan meal' to identify food")
                                    .font(.caption)
                                    .foregroundStyle(.quaternary)
                            }
                            .padding(.vertical, 20)
                            Spacer()
                        }
                    } else {
                        ForEach(foodEntries.prefix(5)) { entry in
                            FoodEntryRowView(entry: entry)
                        }
                    }
                }
                .fullScreenCover(isPresented: $showScanner) {
                    FoodScannerView()
                }
                
                // Powered by Label
                HStack(spacing: 6) {
                    Spacer()
                    Image("VitaSyncIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 18, height: 18)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    
                    Text("VitaSync · powered by AI")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                    Spacer()
                }
                .padding(.top, 8)
            }
            .padding()
        }
        .navigationBarHidden(true)
        .task {
            await viewModel.requestPermissions()
        }
        .refreshable {
            await viewModel.fetchAll()
        }
    }
}
