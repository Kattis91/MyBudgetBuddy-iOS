//
//  PeriodCardView.swift
//  MyBudget
//
//  Created by Katya Durneva Svedmark on 2025-01-16.
//

import SwiftUI

struct PeriodCardView: View {
    let startDate: Date
    let endDate: Date
    
    private var isPeriodActive: Bool {
        let now = Date()
        return now >= startDate && now <= endDate
    }
    
    private var daysRemaining: Int {
        let calendar = Calendar.current
        return calendar.dateComponents([.day], from: Date(), to: endDate).day ?? 0
    }
    
    private var daysUntilNextPeriod: Int {
        let calendar = Calendar.current
        return calendar.dateComponents([.day], from: Date(), to: startDate).day ?? 0
    }
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Current Budget Period")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text(DateUtils.formattedDateRange(startDate: startDate, endDate: endDate))
                .font(.title2)
                .fontWeight(.bold)
            
            // Only show if days remaining is positive
            if isPeriodActive {
                Text("\(daysRemaining) days remaining")
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .shadow(radius: 6)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [.buttonGradientLight, .buttonGradientDark]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                    .cornerRadius(8)
            } else {
                Text("Next period starts in \(daysUntilNextPeriod) days")
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .shadow(radius: 6)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [.buttonGradientLight, .buttonGradientDark]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                    .cornerRadius(8)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [.backgroundTintLight, .backgroundTintDark]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(12)
        .shadow(
            color: .black.opacity(0.1),
            radius: 4,
            x: 0,
            y: 2
        )
        // Add subtle border for more definition
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.3), lineWidth: 0.5)
        )
    }
}

#Preview {
    PeriodCardView(
        startDate: Date(), // Current date
        endDate: Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date() // 30 days from now
    )
}
