//
//  BudgetPeriod.swift
//  MyBudget
//
//  Created by Katya Durneva Svedmark on 2024-12-28.
//

import Foundation

struct BudgetPeriod: Identifiable {
    var id = UUID().uuidString
    var startDate: Date
    var endDate: Date
    var incomes: [Income]
    var fixedExpenses: [Expense]
}
