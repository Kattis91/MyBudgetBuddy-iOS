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

extension BudgetPeriod {
    init?(dict: [String: Any]) {
        guard
            let startDateTimestamp = dict["startDate"] as? TimeInterval,
            let endDateTimestamp = dict["endDate"] as? TimeInterval,
            let incomesData = dict["incomes"] as? [[String: Any]],
            let fixedExpensesData = dict["fixedExpenses"] as? [[String: Any]],
            let variableExpensesData = dict["fixedExpenses"] as? [[String: Any]]
        else { return nil }
        
        // Konvertera start- och slutdatum
        self.startDate = Date(timeIntervalSince1970: startDateTimestamp)
        self.endDate = Date(timeIntervalSince1970: endDateTimestamp)
        
        // Konvertera inkomster manuellt
        var tempIncomes: [Income] = []
        for incomeDict in incomesData {
            if let category = incomeDict["category"] as? String,
               let amount = incomeDict["amount"] as? Double {
                tempIncomes.append(Income(id: id, amount: amount, category: category))
            } else {
                print("Skipping invalid income: \(incomeDict)")
            }
        }
        self.incomes = tempIncomes
        
        // Konvertera fasta utgifter manuellt
        var tempFixedExpenses: [Expense] = []
        for expenseDict in fixedExpensesData {
            if let category = expenseDict["category"] as? String,
               let amount = expenseDict["amount"] as? Double,
               let isfixed = expenseDict["isfixed"] as? Bool {
                tempFixedExpenses.append(Expense(id: id, amount: amount, category: category, isfixed: isfixed))
            } else {
                print("Skipping invalid expense: \(expenseDict)")
            }
        }
        self.fixedExpenses = tempFixedExpenses
        
        // Konvertera rörliga utgifter manuellt
        var tempVariableExpenses: [Expense] = []
        for expenseDict in variableExpensesData {
            if let category = expenseDict["category"] as? String,
               let amount = expenseDict["amount"] as? Double,
               let isfixed = expenseDict["isfixed"] as? Bool {
                tempFixedExpenses.append(Expense(id: id, amount: amount, category: category, isfixed: isfixed))
            } else {
                print("Skipping invalid expense: \(expenseDict)")
            }
        }
        self.variableExpenses = tempVariableExpenses
        
        // Beräkna totaler
        self.totalIncome = self.incomes.reduce(0) { $0 + $1.amount }
        self.totalFixedExpenses = self.fixedExpenses.reduce(0) { $0 + $1.amount }
        self.totalVariableExpenses = self.variableExpenses.reduce(0) { $0 + $1.amount }
        
        self.id = dict["id"] as? String ?? UUID().uuidString
    }
}

extension BudgetPeriod {
    func toDictionary() -> [String: Any] {
        return [
            "id": id,
            "startDate": startDate.timeIntervalSince1970,
            "endDate": endDate.timeIntervalSince1970,
            "incomes": incomes.map { [
                "id": $0.id,
                "amount": $0.amount,
                "category": $0.category
            ] },
            "fixedExpenses": fixedExpenses.map { [
                "id": $0.id,
                "amount": $0.amount,
                "category": $0.category,
                "isfixed": $0.isfixed
            ] },
            "variableExpenses": variableExpenses.map { [
                "id": $0.id,
                "amount": $0.amount,
                "category": $0.category,
                "isfixed": $0.isfixed
            ] },
            "totalIncome": totalIncome,
            "totalFixedExpenses": totalFixedExpenses,
            "totalVariableExpenses": totalVariableExpenses
        ]
    }
}

