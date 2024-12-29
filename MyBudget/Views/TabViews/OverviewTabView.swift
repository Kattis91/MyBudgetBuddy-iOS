//
//  OverviewTabView.swift
//  MyBudget
//
//  Created by Katya Durneva Svedmark on 2024-12-05.
//

import SwiftUI

struct OverviewTabView: View {
    
    @State var showingNewPeriod = false
    @EnvironmentObject var budgetManager: BudgetManager
    
    var body: some View {
        NavigationView {
            List {
                ForEach(budgetManager.historicalPeriods) { historicalPeriod in
                    VStack(alignment: .leading) {
                        Text("Period: \(formatDate(historicalPeriod.startDate)) - \(formatDate(historicalPeriod.endDate))")
                            .font(.headline)
                        Text("Incomes: \(historicalPeriod.allIncomes.count) | Fixed Expenses: \(historicalPeriod.allFixedExpenses.count)")
                            .font(.subheadline)
                                                
                        // Add this to see the actual values
                        VStack(alignment: .leading) {
                            Text("Total Income: \(historicalPeriod.totalIncome, specifier: "%.2f")")
                            Text("Total Fixed Expenses: \(historicalPeriod.totalFixedExpenses, specifier: "%.2f")")
                        }
                        .font(.caption)
                    }
                }
                // Add current period section
                    Section("Current Period") {
                        VStack(alignment: .leading) {
                            Text("Period: \(formatDate(budgetManager.currentPeriod.startDate)) - \(formatDate(budgetManager.currentPeriod.endDate))")
                                .font(.headline)
                            Text("Incomes: \(budgetManager.currentPeriod.incomes.count) | Fixed Expenses: \(budgetManager.currentPeriod.fixedExpenses.count)")
                                .font(.subheadline)
                            
                            let currentTotalIncome = budgetManager.currentPeriod.incomes.reduce(0) { $0 + $1.amount }
                            let currentTotalExpenses = budgetManager.currentPeriod.fixedExpenses.reduce(0) { $0 + $1.amount }
                            
                            VStack(alignment: .leading) {
                                Text("Total Income: \(currentTotalIncome, specifier: "%.2f")")
                                Text("Total Fixed Expenses: \(currentTotalExpenses, specifier: "%.2f")")
                            }
                            .font(.caption)
                        }
                    }
            }
            .navigationTitle("Budget Periods")
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

struct OverviewTabView_Previews: PreviewProvider {
    static var previews: some View {
        OverviewTabView()
            .environmentObject(BudgetManager()) // Lägg till BudgetManager här
    }
}
