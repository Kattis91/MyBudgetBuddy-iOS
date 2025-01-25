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
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 245/255, green: 247/255, blue: 245/255), // Light gray
                        Color(red: 240/255, green: 242/255, blue: 240/255)  // Slightly darker gray
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .cornerRadius(16)
                .shadow(
                    color: .black.opacity(0.25),
                    radius: 1,
                    x: 0,
                    y: 4
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.4), lineWidth: 0.8)
                )
                
                VStack {
                    NavigationLink(destination: PeriodDetailView(period: period)) {
                        HStack (spacing: 10) {
                            VStack (spacing: 8) {
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

