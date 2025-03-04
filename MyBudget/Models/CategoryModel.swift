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
            return [String(localized: "Salary"), String(localized: "Study grant"), String(localized: "Child benefit"), String(localized: "Housing insurance"), String(localized: "Sickness insurance"), String(localized: "Business")]
        case .fixedExpense:
            return [String(localized: "Rent"), String(localized: "Water"), String(localized: "Heat"), String(localized: "Electricity"), String(localized: "Insurance"), String(localized: "WiFi")]
        case .variableExpense:
            return [String(localized: "Groceries"), String(localized: "Dining Out"), String(localized: "Shopping"), String(localized: "Entertainment"), String(localized: "Transport"), String(localized: "Savings")]
        }
    }
}
