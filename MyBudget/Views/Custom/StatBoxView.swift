//
//  StatBoxView.swift
//  MyBudget
//
//  Created by Katya Durneva Svedmark on 2025-01-16.
//

import SwiftUI

struct StatBoxView: View {
    
    let title: String
    let amount: Double
    let isIncome: Bool
    let showNegativeAmount: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: isIncome ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                    .foregroundColor(isIncome ? Color("CustomGreen") : Color("ButtonsBackground"))
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(Color("SecondaryTextColor"))
            }
            
            Text(showNegativeAmount && amount > 0 ? "- \(amount, specifier: "%.2f")" : "\(amount, specifier: "%.2f")")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(Color("SecondaryTextColor"))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
            color: .black.opacity(0.3),
            radius: 2,
            x: -2,
            y: 4
        )
        // Add subtle border for more definition
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.3), lineWidth: 0.5)
        )
    }
}

#Preview {
    StatBoxView(title: "Test", amount: 5, isIncome: true, showNegativeAmount: false)
}
