//
//  BudgetManager.swift
//  MyBudget
//
//  Created by Katya Durneva Svedmark on 2024-12-28.
//

import Foundation

class BudgetManager: ObservableObject {
    
    var budgetfb = BudgetFB()
    
    @Published var currentPeriod: BudgetPeriod
    @Published var periods: [BudgetPeriod] = []
    
    @Published var incomeList: [Income] = []
    @Published var groupedIncome: [String: Double] = [:]
    @Published var totalIncome: Double = 0.0
   
    @Published var fixedExpenseList: [Expense] = []
    @Published var variableExpenseList: [Expense] = []
    @Published var groupedExpense: [String: Double] = [:]
    @Published var totalExpenses: Double = 0.0

   func loadData() async {
       await budgetfb.loadIncomeData()    // Hämta inkomster
       await budgetfb.loadExpenseData()   // Hämta utgifter
       
       await MainActor.run {
           self.incomeList = budgetfb.incomeList
           self.groupedIncome = budgetfb.groupedIncome
           self.totalIncome = budgetfb.totalIncome
           
           self.fixedExpenseList = budgetfb.fixedExpenseList
           self.variableExpenseList = budgetfb.variableExpenseList
           self.groupedExpense = budgetfb.groupedExpense
           self.totalExpenses = budgetfb.totalExpenses
           
           // Update current period with loaded data
           self.currentPeriod.incomes = self.incomeList
           self.currentPeriod.fixedExpenses = self.fixedExpenseList
       }
   }
    
    init() {
        // Exempel: Starta med en första period
        self.currentPeriod = BudgetPeriod(
            startDate: Date(),
            endDate: Calendar.current.date(byAdding: .month, value: 1, to: Date())!,
            incomes: [],
            fixedExpenses: []
        )
        
        periods.append(currentPeriod)
    }
    
    func startNewPeriod(
            startDate: Date,
            endDate: Date,
            includeIncomes: Bool,
            includeFixedExpenses: Bool
        ) {
            
        print("Starting new period...")
        print("Start date: \(startDate)")
        print("End date: \(endDate)")
        print("Include incomes: \(includeIncomes)")
        print("Include expenses: \(includeFixedExpenses)")
            
        // Use the actual loaded data instead of current period
        let newIncomes = includeIncomes ? self.incomeList : []
        let newFixedExpenses = includeFixedExpenses ? self.fixedExpenseList : []
            
        print("Number of incomes to transfer: \(newIncomes.count)")
        print("Number of expenses to transfer: \(newFixedExpenses.count)")

        let newPeriod = BudgetPeriod(
            startDate: startDate,
            endDate: endDate,
            incomes: newIncomes,
            fixedExpenses: newFixedExpenses
        )

        currentPeriod = newPeriod
        periods.append(newPeriod)
        
        print("New period created with start date: \(newPeriod.startDate) and end date: \(newPeriod.endDate)")
        print("Total periods: \(periods.count)")
    }

}
