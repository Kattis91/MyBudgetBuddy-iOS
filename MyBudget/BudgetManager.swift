//
//  BudgetManager.swift
//  MyBudget
//
//  Created by Katya Durneva Svedmark on 2024-12-28.
//

import Foundation
import Firebase
import FirebaseAuth

class BudgetManager: ObservableObject {
    
    var budgetfb = BudgetFB()
    
    @Published var currentPeriod: BudgetPeriod
    @Published var historicalPeriods: [BudgetPeriod] = []
    
    @Published var incomeList: [Income] = []
    @Published var groupedIncome: [String: Double] = [:]
    @Published var totalIncome: Double = 0.0
   
    @Published var fixedExpenseList: [Expense] = []
    @Published var variableExpenseList: [Expense] = []
    @Published var groupedExpense: [String: Double] = [:]
    @Published var totalExpenses: Double = 0.0
    
    init() {
        // Initialize with first period
        self.currentPeriod = BudgetPeriod(
            startDate: Date(),
            endDate: Calendar.current.date(byAdding: .month, value: 1, to: Date())!
        )
    }

   func loadData() async {
       await budgetfb.loadIncomeData()
       await budgetfb.loadExpenseData()
       
       await MainActor.run {
           // Load all data from Firebase
           self.incomeList = budgetfb.incomeList
           self.groupedIncome = budgetfb.groupedIncome
           self.totalIncome = budgetfb.totalIncome
           
           self.fixedExpenseList = budgetfb.fixedExpenseList
           self.variableExpenseList = budgetfb.variableExpenseList
           self.groupedExpense = budgetfb.groupedExpense
           self.totalExpenses = budgetfb.totalExpenses
           
           // Update current period with loaded data
           self.currentPeriod = BudgetPeriod(
               startDate: self.currentPeriod.startDate,
               endDate: self.currentPeriod.endDate,
               incomes: self.incomeList,
               fixedExpenses: self.fixedExpenseList,
               variableExpenses: self.variableExpenseList
           )
       }
   }
    
    func startNewPeriod(
            startDate: Date,
            endDate: Date,
            includeIncomes: Bool,
            includeFixedExpenses: Bool
        ) -> BudgetPeriod {
            
        print("Starting new period...")
        print("Start date: \(startDate)")
        print("End date: \(endDate)")
        print("Include incomes: \(includeIncomes)")
        print("Include expenses: \(includeFixedExpenses)")
            
        historicalPeriods.append(currentPeriod)
            
        // Create new period with only selected data
        let newIncomes = includeIncomes ? incomeList : []
        let newFixedExpenses = includeFixedExpenses ? fixedExpenseList : []
            
        print("Number of incomes to transfer: \(newIncomes.count)")
        print("Number of expenses to transfer: \(newFixedExpenses.count)")

        let newPeriod = BudgetPeriod(
            startDate: startDate,
            endDate: endDate,
            incomes: newIncomes,
            fixedExpenses: newFixedExpenses
        )

        currentPeriod = newPeriod
        
        print("New period created with start date: \(newPeriod.startDate) and end date: \(newPeriod.endDate)")
        print("Total historical periods: \(historicalPeriods.count)")
            
        return newPeriod
    }

}
