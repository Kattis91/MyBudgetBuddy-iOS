//
//  CategoryModel.swift
//  MyBudget
//
//  Created by Katya Durneva Svedmark on 2025-01-10.
//

import Foundation

enum CategoryType: String {
    case income = "incomeCategories"
    case fixedExpense = "fixedExpenseCategories"
    case variableExpense = "variableExpenseCategories"
    
    var defaultCategories: [String] {
        switch self {
        case .income:
            return ["Salary", "Study grant", "Child benefit", "Housing insurance", "Sickness insurance", "Business"]
        case .fixedExpense:
            return ["Rent", "Water", "Heat", "Electricity", "Insurance", "Mobile", "Netflix", "WiFi"]
        case .variableExpense:
            return ["Groceries", "Dining Out", "Shopping", "Entertainment", "Transport", "Savings"]
        }
    }
}
