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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: isIncome ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                    .foregroundColor(isIncome ? .green : .red)
                Text(title)
                    .font(.subheadline)
            }
            
            Text("\(amount, specifier: "%.2f")")
                .font(.title2)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color("TabColor"))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

#Preview {
    StatBoxView(title: "Test", amount: 5, isIncome: true)
}
