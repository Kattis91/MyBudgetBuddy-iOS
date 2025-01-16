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
    
    // Calculate the percentage with safety checks
    private var percentage: Double {
        // Check if income is greater than 0
        guard income > 0 else {
            // If income is 0 or negative, return 0 to avoid division by zero
            return 0
        }
        // If income is positive, calculate the percentage
        return (outcome / income) * 100
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "piggybank.fill")
                    .foregroundColor(.purple)
                Text("Outcome")
                    .font(.headline)
                Spacer()
                Text(percentage == 0 ? "0%" : "\(percentage, specifier: "%.1f")%")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            ProgressView(value: min(max(percentage/100, 0), 1))
                .tint(.purple)
            
            Text("\(outcome, specifier: "%.2f")")
                .font(.title2)
                .fontWeight(.bold)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

#Preview {
    OutcomeBoxView(income: 1000, expenses: 500)
}
