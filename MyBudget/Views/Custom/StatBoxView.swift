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
    
    @Environment(\.colorScheme) var colorScheme
    var isDarkMode: Bool {
        return colorScheme == .dark
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: isIncome ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                    .foregroundColor(isIncome ? Color("CustomGreen") : Color("ButtonsBackground"))
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(Color("PrimaryTextColor"))
            }
            
            Text(showNegativeAmount && amount > 0 ? "- \(amount, specifier: "%.2f")" : "\(amount, specifier: "%.2f")")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(Color("PrimaryTextColor"))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: isDarkMode ?
                   [Color(.darkGray), Color(.black)]  :
                   [.backgroundTintLight, .backgroundTintDark]
                ),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(12)
        .shadow(
            color: isDarkMode ? Color.black.opacity(0.6) : Color.black.opacity(0.3),
            radius: isDarkMode ? 6 : 2,
            x: isDarkMode ? 0 : -2,
            y: isDarkMode ? 6 : 4
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isDarkMode ? Color.white.opacity(0.5) : Color.white.opacity(0.3), lineWidth: isDarkMode ? 0.6 : 0.5)
                .shadow(color: isDarkMode ? Color.white.opacity(0.05) : Color.clear, radius: 5)
        )
    }
}

#Preview {
    StatBoxView(title: "Test", amount: 5, isIncome: true, showNegativeAmount: false)
}
