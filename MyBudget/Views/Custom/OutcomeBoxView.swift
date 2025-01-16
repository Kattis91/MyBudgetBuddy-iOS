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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: isNegative ? "exclamationmark.circle.fill" : "piggybank.fill")
                    .foregroundColor(isNegative ? .red : .purple)
                Text("Outcome")
                    .font(.headline)
                Spacer()
                Text("\(percentage, specifier: "%.1f")%")
                    .font(.subheadline)
                    .foregroundColor(isNegative ? .red : .secondary)
            }
            
            // Custom progress view for negative values
            ZStack(alignment: .leading) {
                Rectangle()
                    .foregroundColor(Color.gray.opacity(0.2))
                    .frame(height: 8)
                    .cornerRadius(4)
                
                Rectangle()
                    .foregroundColor(isNegative ? .red : .purple)
                    .frame(width: abs(min(max(percentage/100, -1), 1)) * UIScreen.main.bounds.width * 0.7, height: 8)
                    .cornerRadius(4)
            }
            
            Text("\(outcome, specifier: "%.2f")")
                .font(.title2)
                .fontWeight(.bold)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isNegative ? Color.red.opacity(0.2) : Color.clear, lineWidth: 1)
        )
    }
}

#Preview {
    OutcomeBoxView(income: 0, expenses: 500)
}
