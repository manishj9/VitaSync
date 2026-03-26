//
//  OnboardingView.swift
//  VitaSync
//
//  Created by Manish Jawale on 26/03/26.
//

import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompleted = false
    @State private var currentPage = 0

    let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "waveform.path.ecg",
            title: "Meet VitaSync",
            subtitle: "Your personal AI health coach that understands your body — automatically.",
            color: Color(hex: "6B4FD8")
        ),
        OnboardingPage(
            icon: "heart.fill",
            title: "Reads your health data",
            subtitle: "VitaSync connects to Apple Health to track steps, heart rate, HRV, and sleep — no manual logging.",
            color: Color(hex: "E05C5C")
        ),
        OnboardingPage(
            icon: "sparkles",
            title: "AI insights, every morning",
            subtitle: "Gemini AI analyzes your data overnight and generates a personalized health insight before you wake up.",
            color: Color(hex: "9B7FF4")
        ),
        OnboardingPage(
            icon: "camera.fill",
            title: "Scan your meals",
            subtitle: "Point your camera at any food and VitaSync identifies it and logs estimated calories instantly.",
            color: Color(hex: "A8F0C6")
        )
    ]

    var body: some View {
        VStack(spacing: 0) {

            // Pages
            TabView(selection: $currentPage) {
                ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                    OnboardingPageView(page: page)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: currentPage)

            // Bottom controls
            VStack(spacing: 20) {

                // Dots
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { i in
                        Circle()
                            .fill(i == currentPage
                                  ? Color.vitaPrimary
                                  : Color.vitaPrimary.opacity(0.25))
                            .frame(width: i == currentPage ? 20 : 8,
                                   height: 8)
                            .animation(.spring(duration: 0.3), value: currentPage)
                    }
                }

                // Button
                Button {
                    if currentPage < pages.count - 1 {
                        withAnimation { currentPage += 1 }
                    } else {
                        hasCompleted = true
                    }
                } label: {
                    Text(currentPage < pages.count - 1 ? "Continue" : "Get started")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.vitaPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }

                if currentPage < pages.count - 1 {
                    Button("Skip") {
                        hasCompleted = true
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 40)
        }
    }
}

struct OnboardingPage: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
}

struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Icon
            ZStack {
                Circle()
                    .fill(page.color.opacity(0.12))
                    .frame(width: 140, height: 140)
                Circle()
                    .fill(page.color.opacity(0.08))
                    .frame(width: 110, height: 110)
                Image(systemName: page.icon)
                    .font(.system(size: 52, weight: .medium))
                    .foregroundStyle(page.color)
            }

            // Text
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.title)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)

                Text(page.subtitle)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 8)
            }

            Spacer()
            Spacer()
        }
        .padding(.horizontal, 28)
    }
}


#Preview {
    OnboardingView()
}
