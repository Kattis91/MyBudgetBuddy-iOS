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
    var variableExpenses: [Expense]
    var totalIncome: Double
    var totalFixedExpenses: Double
    var totalVariableExpenses: Double
    
    init(startDate: Date,
         endDate: Date,
         incomes: [Income] = [],
         fixedExpenses: [Expense] = [],
         variableExpenses: [Expense] = []
    ) {
        self.startDate = startDate
        self.endDate = endDate
        self.incomes = incomes
        self.fixedExpenses = fixedExpenses
        self.variableExpenses = variableExpenses
        self.totalIncome = incomes.reduce(0) { $0 + $1.amount }
        self.totalFixedExpenses = fixedExpenses.reduce(0) { $0 + $1.amount }
        self.totalVariableExpenses = variableExpenses.reduce(0) { $0 + $1.amount }
    }
}

// Firebase Dictionary Conversion
extension BudgetPeriod {
    init?(dict: [String: Any]) {
        // Log the incoming dictionary for debugging
        print("Initializing BudgetPeriod with dictionary:", dict)
        
        guard let startDateTimestamp = dict["startDate"] as? TimeInterval,
              let endDateTimestamp = dict["endDate"] as? TimeInterval
        else {
            print("Failed to get required date timestamps")
            return nil
        }
        
        // Convert dates
        self.startDate = Date(timeIntervalSince1970: startDateTimestamp)
        self.endDate = Date(timeIntervalSince1970: endDateTimestamp)
        
        // Set ID (use existing or create new)
        self.id = dict["id"] as? String ?? UUID().uuidString
        
        // Initialize arrays as empty
        self.incomes = []
        self.fixedExpenses = []
        self.variableExpenses = []
        
        // Convert incomes if present
        if let incomesData = dict["incomes"] as? [[String: Any]] {
            self.incomes = incomesData.compactMap { incomeDict in
                guard let category = incomeDict["category"] as? String,
                      let amount = incomeDict["amount"] as? Double else {
                    print("Skipping invalid income:", incomeDict)
                    return nil
                }
                return Income(
                    id: incomeDict["id"] as? String ?? UUID().uuidString,
                    amount: amount,
                    category: category
                )
            }
        }
        
        // Convert fixed expenses if present
        if let fixedExpensesData = dict["fixedExpenses"] as? [[String: Any]] {
            self.fixedExpenses = fixedExpensesData.compactMap { expenseDict in
                guard let category = expenseDict["category"] as? String,
                      let amount = expenseDict["amount"] as? Double else {
                    print("Skipping invalid fixed expense:", expenseDict)
                    return nil
                }
                return Expense(
                    id: expenseDict["id"] as? String ?? UUID().uuidString,
                    amount: amount,
                    category: category,
                    isfixed: true
                )
            }
        }
        
        // Convert variable expenses if present
        if let variableExpensesData = dict["variableExpenses"] as? [[String: Any]] {
            self.variableExpenses = variableExpensesData.compactMap { expenseDict in
                guard let category = expenseDict["category"] as? String,
                      let amount = expenseDict["amount"] as? Double else {
                    print("Skipping invalid variable expense:", expenseDict)
                    return nil
                }
                return Expense(
                    id: expenseDict["id"] as? String ?? UUID().uuidString,
                    amount: amount,
                    category: category,
                    isfixed: false
                )
            }
        }
        
        // Set totals from dictionary if present, otherwise calculate
        self.totalIncome = dict["totalIncome"] as? Double ?? self.incomes.reduce(0) { $0 + $1.amount }
        self.totalFixedExpenses = dict["totalFixedExpenses"] as? Double ?? self.fixedExpenses.reduce(0) { $0 + $1.amount }
        self.totalVariableExpenses = dict["totalVariableExpenses"] as? Double ?? self.variableExpenses.reduce(0) { $0 + $1.amount }
    }
    
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "id": id,
            "startDate": startDate.timeIntervalSince1970,
            "endDate": endDate.timeIntervalSince1970,
            "totalIncome": totalIncome,
            "totalFixedExpenses": totalFixedExpenses,
            "totalVariableExpenses": totalVariableExpenses
        ]
        
        // Only include arrays if they're not empty
        if !incomes.isEmpty {
            dict["incomes"] = incomes.map { income in
                [
                    "id": income.id,
                    "amount": income.amount,
                    "category": income.category
                ]
            }
        }
        
        if !fixedExpenses.isEmpty {
            dict["fixedExpenses"] = fixedExpenses.map { expense in
                [
                    "id": expense.id,
                    "amount": expense.amount,
                    "category": expense.category,
                    "isfixed": expense.isfixed
                ]
            }
        }
        
        if !variableExpenses.isEmpty {
            dict["variableExpenses"] = variableExpenses.map { expense in
                [
                    "id": expense.id,
                    "amount": expense.amount,
                    "category": expense.category,
                    "isfixed": expense.isfixed
                ]
            }
        }
        
        return dict
    }
}
