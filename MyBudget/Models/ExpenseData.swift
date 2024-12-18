//
//  ExpenseData.swift
//  MyBudget
//
//  Created by Katya Durneva Svedmark on 2024-12-10.
//

import Foundation

class ExpenseData: ObservableObject {
    @Published var totalExpenses: Double = 0.0
    @Published var fixedExpenseList: [Expense] = []
    @Published var variableExpenseList: [Expense] = []

    func addExpense(id: String, amount: Double, category: String, isfixed: Bool) {
        let newExpense = Expense(id: id, amount: amount, category: category, isfixed: isfixed)
        if isfixed {
            fixedExpenseList.append(newExpense)
        } else {
            variableExpenseList.append(newExpense)
        }
        totalExpenses += amount
    }
}
