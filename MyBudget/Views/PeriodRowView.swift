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
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        
        if isCurrent {
            SummaryBoxView(period: period, isCurrent: true)
        } else {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: colorScheme == .dark ? [
                        Color(.darkGray), Color(.black)
                    ] : [
                        Color(red: 245/255, green: 247/255, blue: 245/255),
                        Color(red: 240/255, green: 242/255, blue: 240/255)
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .cornerRadius(16)
                .shadow(
                    color: colorScheme == .dark ?
                        .black.opacity(0.35) :
                        .black.opacity(0.25),
                    radius: colorScheme == .dark ? 2 : 1,
                    x: -2,
                    y: 4
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            colorScheme == .dark ?
                                Color.white.opacity(0.2) :
                                Color.white.opacity(0.4),
                            lineWidth: 0.8
                        )
                )
                
                VStack {
                    NavigationLink(destination: PeriodDetailView(period: period)) {
                        HStack (spacing: 10) {
                            VStack (spacing: 8) {
                                Text(DateUtils.formattedDateRange(startDate: period.startDate, endDate: period.endDate))
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color("PrimaryTextColor"))
                                Text("Outcome: \(period.totalIncome - (period.totalFixedExpenses + period.totalVariableExpenses), specifier: "%.2f")")
                                    .foregroundStyle(Color("PrimaryTextColor"))
                            }
                            Spacer()
                            
                            Image(systemName: "info.circle.fill")
                                .foregroundStyle(Color("PrimaryTextColor"))
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding()
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

