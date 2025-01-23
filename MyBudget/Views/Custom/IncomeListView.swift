//
//  IncomeListView.swift
//  MyBudget
//
//  Created by Katya Durneva Svedmark on 2025-01-23.
//

import SwiftUI

struct IncomeListView: View {
   
    let incomes: [Income]
    let total: Double
    
    var body: some View {
        List {
            Section(header: Text("Total: \(total, specifier: "%.2f")")) {
                ForEach(incomes) { income in
                    HStack {
                        Text(income.category)
                        Spacer()
                        Text("\(income.amount, specifier: "%.2f")")
                            .fontWeight(.semibold)
                    }
                }
            }
        }
    }
}

#Preview {
    IncomeListView(
        incomes: [
            Income(id: UUID().uuidString, amount: 1000.0, category: "Salary")
        ],
        total: 1800.0
    )
}
