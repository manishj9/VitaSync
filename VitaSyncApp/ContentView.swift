//
//  ContentView.swift
//  VitaSync
//
//  Created by Manish Jawale on 19/03/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompleted = false

    var body: some View {
        if hasCompleted {
            TabView {
                Tab("Home", systemImage: "house.fill") {
                    NavigationStack { HomeView() }
                }
                Tab("Trends", systemImage: "chart.line.uptrend.xyaxis") {
                    NavigationStack { TrendsView() }
                }
                Tab("Food", systemImage: "fork.knife") {
                    NavigationStack { FoodLogView() }
                }
            }
            .tint(.vitaPrimary)
        } else {
            OnboardingView()
        }
    }
}
