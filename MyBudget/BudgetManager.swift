//
//  BudgetManager.swift
//  MyBudget
//
//  Created by Katya Durneva Svedmark on 2024-12-28.
//

import Foundation
import Firebase
import FirebaseAuth

extension Notification.Name {
    static let periodUpdated = Notification.Name("periodUpdated")
}

extension Notification.Name {
    static let HistoricalPeriodsUpdated = Notification.Name("HistoricalPeriodsUpdated")
}

class BudgetManager: ObservableObject {
    
    var budgetfb = BudgetFB()
    
    @Published var currentPeriod: BudgetPeriod = BudgetPeriod(
        startDate: Date(),
        endDate: Date(),
        incomes: [],
        fixedExpenses: [],
        variableExpenses: []
    )
        
    @Published var historicalPeriods: [BudgetPeriod] = []
    
    @Published var incomeList: [Income] = []
    @Published var groupedIncome: [String: Double] = [:]
    @Published var totalIncome: Double = 0.0
   
    @Published var fixedExpenseList: [Expense] = []
    @Published var variableExpenseList: [Expense] = []
    @Published var groupedExpense: [String: Double] = [:]
    @Published var totalExpenses: Double = 0.0
    
    @Published var invoices: [Invoice] = []
    
    init() {
        // Initialize with first period
        self.currentPeriod = BudgetPeriod(
            startDate: Date(),
            endDate: Calendar.current.date(byAdding: .month, value: 1, to: Date())!
        )
    }

   func loadData() async {
       await budgetfb.loadIncomeData()
       await budgetfb.loadExpenseData(isfixed: true)
       await budgetfb.loadExpenseData(isfixed: false)
       
       // Load historical periods
       let historicalPeriods = await budgetfb.loadHistoricalPeriods()
       await MainActor.run {
           self.historicalPeriods = historicalPeriods
       }

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
    
    func updateCurrentPeriodData(_ period: BudgetPeriod) async {
        await MainActor.run {
            self.currentPeriod = period
            self.incomeList = period.incomes
            self.fixedExpenseList = period.fixedExpenses
            self.variableExpenseList = period.variableExpenses
            updateGroupedData()
            NotificationCenter.default.post(name: .periodUpdated, object: nil)
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
        
        // Create transferred data for new period
        let transferredIncomes = includeIncomes ? incomeList.map { Income(
            id: UUID().uuidString, // Generate new IDs for the new period
            amount: $0.amount,
            category: $0.category
        ) } : []
        
        let transferredFixedExpenses = includeFixedExpenses ? fixedExpenseList.map { Expense(
            id: UUID().uuidString, // Generate new IDs for the new period
            amount: $0.amount,
            category: $0.category,
            isfixed: $0.isfixed
        ) } : []
        
        // Create new period
        let newPeriod = BudgetPeriod(
            startDate: startDate,
            endDate: endDate,
            incomes: transferredIncomes,
            fixedExpenses: transferredFixedExpenses,
            variableExpenses: [],
            expired: false
        )
        
        currentPeriod = newPeriod
        
        // Clear current lists and update with transferred data
        incomeList = transferredIncomes
        fixedExpenseList = transferredFixedExpenses
        variableExpenseList = []
        
        // Update grouped data and totals
        updateGroupedData()
        
        return newPeriod
    }
    
    // Add this helper method to BudgetManager
    private func updateGroupedData() {
        // Update income grouping and total
        groupedIncome = Dictionary(grouping: incomeList) { $0.category }
            .mapValues { incomes in
                incomes.reduce(0) { $0 + $1.amount }
            }
        totalIncome = incomeList.reduce(0) { $0 + $1.amount }
        
        // Update expense grouping and total
        let allExpenses = fixedExpenseList + variableExpenseList
        groupedExpense = Dictionary(grouping: allExpenses) { $0.category }
            .mapValues { expenses in
                expenses.reduce(0) { $0 + $1.amount }
            }
        totalExpenses = allExpenses.reduce(0) { $0 + $1.amount }
    }
    
    func loadInvoices() async {
        let loadedInvoices = await budgetfb.loadInvoices()
        await MainActor.run {
            self.invoices = loadedInvoices
        }
    }
}
