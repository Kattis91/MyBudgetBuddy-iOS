//
//  PeriodRowView.swift
//  MyBudget
//
//  Created by Katya Durneva Svedmark on 2025-01-22.
//

import SwiftUI

struct PeriodRowView: View {
    let period: BudgetPeriod
    let isCurrent: Bool
    
    var body: some View {
        
        if isCurrent {
            SummaryBoxView(period: period, isCurrent: true)
        } else {
            VStack {
                NavigationLink(destination: PeriodDetailView(period: period)) {
                   HStack {
                       VStack {
                           Text(DateUtils.formattedDateRange(startDate: period.startDate, endDate: period.endDate))
                               .fontWeight(.bold)
                               .foregroundStyle(.black)
                           Text("Balance: \(period.totalIncome - (period.totalFixedExpenses + period.totalVariableExpenses), specifier: "%.2f")")
                               .foregroundStyle(.black)
                       }
                       Spacer()
                   }
               }
            }
        }
    }
}


#Preview {
    PeriodRowView(period: BudgetPeriod(
        startDate: Date(),
        endDate: Date().addingTimeInterval(86400 * 30),
        incomes: [],
        fixedExpenses: [],
        variableExpenses: []
    ), isCurrent: true)
}

