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
    
    @Environment(\.colorScheme) var colorScheme
    var isDarkMode: Bool {
        return colorScheme == .dark
    }
    
    var body: some View {
        VStack {
            // Summary card
            SummaryBoxView(period: period, isCurrent: false)
                .padding(.horizontal, isDarkMode ? 15 : 20)
                .padding(.bottom, 30)
                .padding(.top, 15)
            
            // Add segmented control
            Picker("Category", selection: $selectedTab) {
                Text("Incomes").tag(0)
                Text("Fixed").tag(1)
                Text("Variable").tag(2)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal, isDarkMode ? 15 : 20)
            .padding(.bottom, 15)
            
            // Add tab view content
            switch selectedTab {
            case 0:
                CustomListView(
                    items: period.incomes,
                    deleteAction: nil,
                    itemContent: { income in
                        (category: income.category, amount: income.amount, date: nil)
                    },
                    isCurrent: false,
                    showNegativeAmount: false,
                    alignAmountInMiddle: false,
                    isInvoice: false,
                    onMarkProcessed: nil
                )
            case 1:
                CustomListView(
                    items: period.fixedExpenses,
                    deleteAction: nil,
                    itemContent: { expense in
                        (category: expense.category, amount: expense.amount, date: nil)
                    },
                    isCurrent: false,
                    showNegativeAmount: true,
                    alignAmountInMiddle: false,
                    isInvoice: false,
                    onMarkProcessed: nil
                )
            case 2:
                CustomListView(
                    items: period.variableExpenses,
                    deleteAction: nil,
                    itemContent: { expense in
                        (category: expense.category, amount: expense.amount, date: nil)
                    },
                    isCurrent: false,
                    showNegativeAmount: true,
                    alignAmountInMiddle: false,
                    isInvoice: false,
                    onMarkProcessed: nil
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

