//
//  PeriodDetailView.swift
//  MyBudget
//
//  Created by Katya Durneva Svedmark on 2025-01-22.
//

import SwiftUI

struct PeriodDetailView: View {
    let period: BudgetPeriod
    @State private var selectedTab = 0
    
    var body: some View {
        VStack {
            // Summary card
            VStack(spacing: 12) {
                Text(DateUtils.formattedDateRange(startDate: period.startDate, endDate: period.endDate))
                    .font(.headline)
                
                HStack(spacing: 20) {
                    SummaryBoxView(
                        title: "Income",
                        amount: period.totalIncome,
                        color: Color(red: 78/255, green: 177/255, blue: 181/255)
                    )
                    SummaryBoxView(
                        title: "Expenses",
                        amount: period.totalFixedExpenses + period.totalVariableExpenses,
                        color: Color(red: 174/255, green: 41/255, blue: 114/255)
                    )
                    SummaryBoxView(
                        title: "Balance",
                        amount: period.totalIncome - (period.totalFixedExpenses + period.totalVariableExpenses),
                        color: Color(red: 67/255, green: 135/255, blue: 221/255)
                    )
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(10)
            .shadow(radius: 1)
            .padding()
            
            // Add segmented control
            Picker("Category", selection: $selectedTab) {
                Text("Incomes").tag(0)
                Text("Fixed").tag(1)
                Text("Variable").tag(2)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            
            // Add tab view content
            switch selectedTab {
            case 0:
                IncomeListView(incomes: period.incomes, total: period.totalIncome)
            case 1:
                ExpenseListView(expenses: period.fixedExpenses, total: period.totalFixedExpenses, isFixed: true)
            case 2:
                ExpenseListView(expenses: period.variableExpenses, total: period.totalVariableExpenses, isFixed: false)
            default:
                EmptyView()
            }
            
            Spacer()
        }
        .navigationTitle("Period Details")
    }
}

#Preview {
    PeriodDetailView(period: BudgetPeriod(
        startDate: Date(),
        endDate: Date().addingTimeInterval(86400 * 30),
        incomes: [],
        fixedExpenses: [],
        variableExpenses: []
    ))
}

