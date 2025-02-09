//
//  SummaryBoxView.swift
//  MyBudget
//
//  Created by Katya Durneva Svedmark on 2025-01-23.
//

import SwiftUI

struct SummaryBoxView: View {
    let period: BudgetPeriod
    let isCurrent: Bool
    
    var body: some View {
        VStack {
            VStack {
                Text(isCurrent ? "Current Period" : "")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(Color("SecondaryTextColor"))
                Text(DateUtils.formattedDateRange(startDate: period.startDate, endDate: period.endDate))
                    .fontWeight(isCurrent ? .medium : .bold)
                    .foregroundStyle(Color("SecondaryTextColor"))
            }
            .frame(maxWidth: .infinity, alignment: .center)
            
            HStack() {
                VStack {
                    Text("\(period.totalIncome, specifier: "%.2f")")
                        .foregroundStyle(Color(red: 78/255, green: 177/255, blue: 181/255))
                        .fontWeight(.bold)
                        .font(.title3)
                    Text("Income")
                        .foregroundStyle(Color("SecondaryTextColor"))
                }
                VStack {
                    Text("\(period.totalFixedExpenses + period.totalVariableExpenses, specifier: "%.2f")")
                        .foregroundStyle(Color(red: 174/255, green: 41/255, blue: 114/255))
                        .fontWeight(.bold)
                        .font(.title3)
                    Text("Expenses")
                        .foregroundStyle(Color("SecondaryTextColor"))
                }
                .padding(.horizontal, 6)
                VStack {
                    Text("\(period.totalIncome - (period.totalFixedExpenses + period.totalVariableExpenses), specifier: "%.2f")")
                        .foregroundStyle(Color(red: 67/255, green: 135/255, blue: 221/255))
                        .fontWeight(.bold)
                        .font(.title3)
                    Text("Outcome")
                        .foregroundStyle(Color("SecondaryTextColor"))
                }
            }
            .padding(.vertical, 10)
        }
        .padding(.vertical, 4)
        .frame(maxWidth: .infinity, alignment: .center)
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [.backgroundTintLight, .backgroundTintDark]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .shadow(
            color: .black.opacity(0.3),
            radius: 4,
            x: 0,
            y: 2
        )
        // Add subtle border for more definition
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.3), lineWidth: 0.5)
        )
    }
}

#Preview {
    SummaryBoxView(period: BudgetPeriod(
        startDate: Date(),
        endDate: Date().addingTimeInterval(86400 * 30),
        incomes: [],
        fixedExpenses: [],
        variableExpenses: []
    ), isCurrent: true)
}
