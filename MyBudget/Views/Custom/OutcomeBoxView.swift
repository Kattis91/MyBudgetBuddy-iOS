//
//  OutcomeBoxView.swift
//  MyBudget
//
//  Created by Katya Durneva Svedmark on 2025-01-16.
//

import SwiftUI

struct OutcomeBoxView: View {
    let income: Double
    let expenses: Double
    
    private var outcome: Double {
        income - expenses
    }
    
    private var percentage: Double {
        if income > 0 {
            return (outcome / income) * 100
        } else if expenses > 0 {
            return -100 // Show -100% when there's no income but has expenses
        } else {
            return 0 // Only show 0% when both income and expenses are 0
        }
    }
    
    private var isNegative: Bool {
        outcome < 0
    }
    
    @Environment(\.colorScheme) var colorScheme
    var isDarkMode: Bool {
        return colorScheme == .dark
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: isNegative ? "exclamationmark.circle.fill" : "checkmark.circle.fill")
                    .foregroundColor(isNegative ? Color("ButtonsBackground") : Color("CustomGreen"))
                Text("Outcome")
                    .font(.headline)
                    .foregroundStyle(Color("PrimaryTextColor"))
                Spacer()
                Text("\(percentage, specifier: "%.1f")%")
                    .font(.subheadline)
                    .foregroundStyle(Color("PrimaryTextColor"))
                    .fontWeight(.bold)
            }
            
            // Custom progress view for negative values
            ZStack(alignment: .leading) {
                Rectangle()
                    .foregroundColor(Color.gray.opacity(0.2))
                    .frame(height: 8)
                    .cornerRadius(4)
                
                Rectangle()
                    .foregroundColor(isNegative ? Color("ButtonsBackground") : Color("CustomGreen"))
                    .frame(width: abs(min(max(percentage/100, -1), 1)) * UIScreen.main.bounds.width * 0.7, height: 8)
                    .cornerRadius(4)
            }
            
            Text("\(outcome, specifier: "%.2f")")
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
            x: 0,
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
    OutcomeBoxView(income: 0, expenses: 500)
}
