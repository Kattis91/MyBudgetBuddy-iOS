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

    func addExpense(amount: Double, category: String, isFixed: Bool) {
        let newExpense = Expense(amount: amount, category: category)
        if isFixed {
            fixedExpenseList.append(newExpense)
        } else {
            variableExpenseList.append(newExpense)
        }
        totalExpenses += amount
    }

    func deleteExpense(at offsets: IndexSet, isFixed: Bool) {
        if isFixed {
            for index in offsets {
                totalExpenses -= fixedExpenseList[index].amount
            }
            fixedExpenseList.remove(atOffsets: offsets)
        } else {
            for index in offsets {
                totalExpenses -= variableExpenseList[index].amount
            }
            variableExpenseList.remove(atOffsets: offsets)
        }
    }
}
