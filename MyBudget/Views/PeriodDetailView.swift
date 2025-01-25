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
            SummaryBoxView(period: period, isCurrent: false)
                .padding(.horizontal, 34)
                .padding(.vertical, 30)
            
            // Add segmented control
            Picker("Category", selection: $selectedTab) {
                Text("Incomes").tag(0)
                Text("Fixed").tag(1)
                Text("Variable").tag(2)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal, 34)
            
            // Add tab view content
            switch selectedTab {
            case 0:
                CustomListView(
                    items: period.incomes,
                    deleteAction: nil,
                    itemContent: { income in
                        (category: income.category, amount: income.amount)
                    },
                    showNegativeAmount: false
                )
            case 1:
                CustomListView(
                    items: period.fixedExpenses,
                    deleteAction: nil,
                    itemContent: { expense in
                        (category: expense.category, amount: expense.amount)
                    },
                    showNegativeAmount: true
                )
            case 2:
                CustomListView(
                    items: period.variableExpenses,
                    deleteAction: nil,
                    itemContent: { expense in
                        (category: expense.category, amount: expense.amount)
                    },
                    showNegativeAmount: true
                )
            default:
                EmptyView()
            }
            
            Spacer()
        }
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

