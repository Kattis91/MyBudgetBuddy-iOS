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
    
    @Environment(\.colorScheme) var colorScheme
    var isDarkMode: Bool {
        return colorScheme == .dark
    }
    
    var body: some View {
        VStack {
            VStack {
                Text(isCurrent ? "Current Period" : "")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(Color("PrimaryTextColor"))
                Text(DateUtils.formattedDateRange(startDate: period.startDate, endDate: period.endDate))
                    .fontWeight(isCurrent ? .medium : .bold)
                    .foregroundStyle(Color("PrimaryTextColor"))
            }
            .frame(maxWidth: .infinity, alignment: .center)
            
            HStack() {
                VStack {
                    Text("\(period.totalIncome, specifier: "%.2f")")
                        .foregroundStyle(Color(red: 78/255, green: 177/255, blue: 181/255))
                        .fontWeight(.bold)
                        .font(.title3)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                    Text("Income")
                        .foregroundStyle(Color("PrimaryTextColor"))
                }
                VStack {
                    Text("\(period.totalFixedExpenses + period.totalVariableExpenses, specifier: "%.2f")")
                        .foregroundStyle(Color(red: 174/255, green: 41/255, blue: 114/255))
                        .fontWeight(.bold)
                        .font(.title3)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                    Text("Expenses")
                        .foregroundStyle(Color("PrimaryTextColor"))
                }
                .padding(.horizontal, 6)
                VStack {
                    Text("\(period.totalIncome - (period.totalFixedExpenses + period.totalVariableExpenses), specifier: "%.2f")")
                        .foregroundStyle(Color(red: 67/255, green: 135/255, blue: 221/255))
                        .fontWeight(.bold)
                        .font(.title3)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                    Text("Outcome")
                        .foregroundStyle(Color("PrimaryTextColor"))
                }
            }
            .padding(.vertical, 10)
        }
        .padding(.vertical, 4)
        .frame(maxWidth: .infinity, alignment: .center)
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: isDarkMode ?
                    [.darkGradientStart, .darkGradientEnd] :
                    [.backgroundTintLight, .backgroundTintDark]
                ),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .shadow(
            color: isDarkMode ?
                Color.black.opacity(0.25) :
                Color.black.opacity(0.3),
            radius: isDarkMode ? 3 : 1,
            x: isDarkMode ? 0 : -2,
            y: 3
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    isDarkMode ?
                        Color.white.opacity(0.08) :
                        Color.white.opacity(0.3),
                    lineWidth: 0.5
                )
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
