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
    
    private var formattedDateRange: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"  // This will show "Jan 17"
        let yearFormatter = DateFormatter()
        yearFormatter.dateFormat = "yyyy"
        
        let startStr = formatter.string(from: startDate)
        let endStr = formatter.string(from: endDate)
        let yearStr = yearFormatter.string(from: endDate)
        
        return "\(startStr) - \(endStr), \(yearStr)"
    }
    
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
            
            Text(formattedDateRange)
                .font(.title2)
                .fontWeight(.bold)
            
            // Only show if days remaining is positive
            if isPeriodActive {
                Text("\(daysRemaining) days remaining")
                    .font(.subheadline)
                    .foregroundColor(.black)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.purple.opacity(0.1))
                    .cornerRadius(8)
            } else {
                Text("Next period starts in \(daysUntilNextPeriod) days")
                    .font(.subheadline)
                    .foregroundColor(.black)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.purple.opacity(0.1))
                    .cornerRadius(8)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [.backgroundTint, .cardShadow]),
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

#Preview {
    PeriodCardView(
        startDate: Date(), // Current date
        endDate: Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date() // 30 days from now
    )
}
