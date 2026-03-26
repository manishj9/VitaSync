//
//  FoodScannerView.swift
//  VitaSyncApp
//
//  Created by Manish Jawale on 21/03/26.
//

import  SwiftUI
import SwiftData

struct FoodScannerView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = FoodScannerViewModel()
    var body: some View {
        ZStack {
            // Camera feed or captured image
            if let captured = viewModel.capturedImage {
                Image(uiImage: captured)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            } else {
                CameraView(session: viewModel.session)
                    .ignoresSafeArea()
            }
            
            // Dark overlay at bottom
            VStack {
                Spacer()
                Rectangle()
                    .fill(.black.opacity(0.55))
                    .frame(height: 280)
            }
            .ignoresSafeArea()
            
            // UI Layer
            VStack {
                // Top bar
                HStack {
                    Button {
                        viewModel.stopCamera()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(.white)
                            .padding(10)
                            .background(.black.opacity(0.4))
                            .clipShape(Circle())
                    }
                    Spacer()
                    Text("Scan Food")
                        .font(.headline)
                        .foregroundStyle(.white)
                    Spacer()
                    
                    // Balance Layout
                    Color.clear.frame(width: 38, height: 38)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                
                Spacer()
                
                // Result card or capture button
                VStack(spacing: 16) {
                    if viewModel.isScanning {
                        
                        ScanningIndicatorView()
                        
                    } else if let result = viewModel.result {
                        FoodResultView(
                            result: result,
                            isSaved: viewModel.isSaved,
                            onSave: {
                                viewModel.saveEntry(context: modelContext)
                            },
                            onRescan: {
                                viewModel.reset()
                            }
                        )
                    } else {
                        // Capture Button
                        VStack(spacing: 12) {
                            Text("Point at your food and tap scan")
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.8))
                            
                            Button {
                                
                                Task {
                                    await viewModel.captureAndClassify()
                                }
                            } label: {
                                ZStack {
                                    Circle()
                                        .fill(.white)
                                        .frame(width: 72, height: 72)
                                    Circle()
                                        .fill(Color.vitaPrimary)
                                        .frame(width: 58, height: 58)
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 22))
                                        .foregroundStyle(.white)
                                }
                            }
                        }
                    }
                }
                .padding(.bottom, 48)
                .padding(.horizontal, 24)
            }
        }
        .onAppear { viewModel.setupCamera() }
        .onDisappear { viewModel.stopCamera() }
    }
}

// MARK: Scanning Indicator

struct ScanningIndicatorView: View {
    @State private var pulse = false
    
    var body: some View {
        VStack(spacing: 12) {
            Circle()
                .fill(Color.vitaPrimary.opacity(0.2))
                .frame(width: 64, height: 64)
                .scaleEffect(pulse ? 1.3 : 1.0)
                .animation(.easeInOut(duration: 0.8).repeatForever(), value: pulse)
            ProgressView()
                .tint(.white)
                .scaleEffect(1.2)
        }
        .onAppear{ pulse = true }
        
        Text("Identifying food...")
            .font(.subheadline)
            .foregroundStyle(.white)
        
    }
}

// MARK: - Food Result Card

struct FoodResultView: View {
    let result: FoodClassificationResult
    let isSaved: Bool
    let onSave: () -> Void
    let onRescan: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            
            // Food Name + Confidence
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(result.name)
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundStyle(.white)
                    Text(result.confidencePercent)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                }
                Spacer()
                // Calorie Badge
                VStack(spacing: 2){
                    Text("\(result.calories)")
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundStyle(Color.vitaMint)
                    Text("kcal")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
            
            // Reliability Warning
            if !result.isReliable {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.caption)
                        .foregroundStyle(.yellow)
                    Text("Low confidence - calories are an estimate")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
            
            // Action buttons
            HStack(spacing: 12) {
                Button(action: onRescan) {
                    Label("Rescan", systemImage: "arrow.counterclockwise")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(.white.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                Button(action: onSave) {
                    Label(
                        isSaved ? "Saved!" : "Log meal",
                        systemImage: isSaved ? "checkmark.circle.fill" : "plus.circle.fill"
                    )
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(isSaved ? Color.vitaMint : .black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(isSaved ? Color.vitaMint.opacity(0.3) : .white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(isSaved)
            }
        }
        .padding(18)
        .background(.black.opacity(0.4))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

#Preview {
    FoodScannerView()
}
