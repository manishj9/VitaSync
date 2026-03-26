//
//  InsightCardView.swift
//  VitaSyncApp
//
//  Created by Manish Jawale on 19/03/26.
//

import SwiftUI

struct InsightCardView: View {
    let text : String
    var isLoading: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            // Badge
            HStack(spacing: 6) {
                Image("VitaSyncIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                
                Text("VitaSync insight")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.vitaPrimary)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color.vitaPrimary.opacity(0.1))
            .clipShape(Capsule())
            
            // Insight text or shimmer
            if isLoading {
                VStack(alignment: .leading, spacing: 8) {
                    ShimmerRow(width: .infinity)
                    ShimmerRow(width: .infinity)
                    ShimmerRow(width: 200)
                }
            } else {
                Text(text)
                    .font(.subheadline)
                    .lineSpacing(5)
                    .foregroundStyle(.primary)
                    .transition(.opacity)
                
            }
            
            // Footer
            HStack(spacing: 5) {
                Circle()
                    .fill(Color.vitaMint)
                    .frame(width: 10, height: 10)
                Text("Generated from your last 7 days")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                }
            }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.background)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.vitaPrimary.opacity(0.25), lineWidth: 0.5)
                )
                .animation(.easeInOut(duration: 0.3), value: isLoading)
        }
        
    }
    
    // Shimmer Placeholder Row
    struct ShimmerRow: View {
        var width : CGFloat
        
        var body: some View {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.vitaPrimary.opacity(0.08))
                .frame(maxWidth: width == .infinity ? .infinity: width)
                .frame(height: 12)
        }
    }
