//
//  SummaryBoxView.swift
//  MyBudget
//
//  Created by Katya Durneva Svedmark on 2025-01-23.
//

import SwiftUI

struct SummaryBoxView: View {
    let title: String
    let amount: Double
    let color: Color
    
    var body: some View {
        VStack {
            Text("\(amount, specifier: "%.2f")")
                .foregroundStyle(color)
                .fontWeight(.bold)
                .font(.title3)
            Text(title)
        }
    }
}

#Preview {
    SummaryBoxView(title: "Income", amount: 20000, color: .green)
}
