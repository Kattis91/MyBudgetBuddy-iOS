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
    @State private var isExpanded = false
    
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
                        Text("\(period.totalIncome, specifier: "%.2f")")
                            .foregroundStyle(Color(red: 78 / 255, green: 177 / 255, blue: 181 / 255))
                            .fontWeight(.bold)
                            .font(.title3)
                        Text("Incomes")
                    }
                    VStack {
                        Text("\((period.totalFixedExpenses + period.totalVariableExpenses), specifier: "%.2f")")
                            .foregroundStyle(Color(red: 174 / 255, green: 41 / 255, blue: 114 / 255))
                            .fontWeight(.bold)
                            .font(.title3)
                        Text("Expenses")
                    }
                    .padding(.horizontal, 6)
                    VStack {
                        Text("\(period.totalIncome - (period.totalFixedExpenses + period.totalVariableExpenses), specifier: "%.2f")")
                            .foregroundStyle(Color(red: 67 / 255, green: 135 / 255, blue: 221 / 255))
                            .fontWeight(.bold)
                            .font(.title3)
                        Text("Balance")
                    }
                }
                .padding(.vertical, 10)
            }
            .padding(.vertical, 4)
        } else {
            VStack {
                Button(action: { isExpanded.toggle() }) {
                   HStack {
                       VStack {
                           Text(DateUtils.formattedDateRange(startDate: period.startDate, endDate: period.endDate))
                               .fontWeight(.bold)
                               .foregroundStyle(.black)
                           Text("Balance: \(period.totalIncome - (period.totalFixedExpenses + period.totalVariableExpenses), specifier: "%.2f")")
                               .foregroundStyle(.black)
                       }
                       Spacer()
                       Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                   }
               }
            }
            if isExpanded {
                VStack(alignment: .leading) {
                    Text("Total Income: \(period.totalIncome, specifier: "%.2f")")
                    Text("Total Fixed Expenses: \(period.totalFixedExpenses, specifier: "%.2f")")
                    Text("Total Variable Expenses: \(period.totalVariableExpenses, specifier: "%.2f")")
                }
                .font(.caption)
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

