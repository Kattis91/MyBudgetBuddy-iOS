//
//  ExpenseListView.swift
//  MyBudget
//
//  Created by Katya Durneva Svedmark on 2025-01-23.
//

import SwiftUI

struct ExpenseListView: View {
   
    let expenses: [Expense]
    let total: Double
    let isFixed: Bool
    
    var body: some View {
        List {
            Section(header: Text("Total: \(total, specifier: "%.2f")")) {
                ForEach(expenses) { expense in
                    HStack {
                        Text(expense.category)
                        Spacer()
                        Text("\(expense.amount, specifier: "%.2f")")
                            .fontWeight(.semibold)
                    }
                }
            }
        }
    }
}

#Preview {
    ExpenseListView(
        expenses: [
            Expense(id: UUID().uuidString, amount: 1000.0, category: "Rent", isfixed: true)
    ],
    total: 1800.0, isFixed: true)
}
