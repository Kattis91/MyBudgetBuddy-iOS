//
//  IncomeData.swift
//  MyBudget
//
//  Created by Katya Durneva Svedmark on 2024-12-10.
//

import Foundation

class IncomeData: ObservableObject {
    @Published var totalIncome: Double = 0.0
    @Published var incomeList: [Income] = []
    
    func addIncome(id: String, amount: Double, category: String) {
        let newIncome = Income(id: id, amount: amount, category: category)
        incomeList.append(newIncome)
        totalIncome += amount
    }
}
