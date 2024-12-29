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
                Section("Current Period") {
                    PeriodRowView(period: budgetManager.currentPeriod, isCurrent: true)
                }
                
                Section("Historical Periods") {
                    ForEach(budgetManager.historicalPeriods.reversed()) { period in
                        PeriodRowView(period: period, isCurrent: false)
                    }
                }
            }
            .navigationTitle("Budget Periods")
            .toolbar {
                Button("New Period") {
                    showingNewPeriod = true
                }
            }
        }
    }
}

struct PeriodRowView: View {
    let period: BudgetPeriod
    let isCurrent: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("\(isCurrent ? "Current Period" : "Period"): \(formatDate(period.startDate)) - \(formatDate(period.endDate))")
                .font(.headline)
            Text("Incomes: \(period.incomes.count) | Fixed Expenses: \(period.fixedExpenses.count) | Variable Expenses: \(period.variableExpenses.count)")
                .font(.subheadline)
            
            VStack(alignment: .leading) {
                Text("Total Income: \(period.totalIncome, specifier: "%.2f")")
                Text("Total Fixed Expenses: \(period.totalFixedExpenses, specifier: "%.2f")")
                Text("Total Variable Expenses: \(period.totalVariableExpenses, specifier: "%.2f")")
            }
            .font(.caption)
        }
        .padding(.vertical, 4)
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
