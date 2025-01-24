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
            VStack {
                VStack {
                    Text("Current Period")
                        .font(.headline)
                    Text(DateUtils.formattedDateRange(startDate: period.startDate, endDate: period.endDate))
                }
                .frame(maxWidth: .infinity, alignment: .center)
                
                HStack() {
                    VStack {
                        SummaryBoxView(
                            title: "Income",
                            amount: period.totalIncome,
                            color: Color(red: 78/255, green: 177/255, blue: 181/255)
                        )
                    }
                    VStack {
                        SummaryBoxView(
                            title: "Expenses",
                            amount: period.totalFixedExpenses + period.totalVariableExpenses,
                            color: Color(red: 174/255, green: 41/255, blue: 114/255)
                        )
                    }
                    .padding(.horizontal, 6)
                    VStack {
                        SummaryBoxView(
                            title: "Balance",
                            amount: period.totalIncome - (period.totalFixedExpenses + period.totalVariableExpenses),
                            color: Color(red: 67/255, green: 135/255, blue: 221/255)
                        )
                    }
                }
                .padding(.vertical, 10)
            }
            .padding(.vertical, 4)
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

