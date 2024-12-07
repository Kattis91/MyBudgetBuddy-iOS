//
//  ExpenseModel.swift
//  MyBudget
//
//  Created by Katya Durneva Svedmark on 2024-12-07.
//

import Foundation

struct Expense: Identifiable {
    let id = UUID()
    let amount: Double
    let category: String
}
