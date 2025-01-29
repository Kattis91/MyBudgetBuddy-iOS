//
//  OverviewTabView.swift
//  MyBudget
//
//  Created by Katya Durneva Svedmark on 2024-12-05.
//

import SwiftUI

struct OverviewTabView: View {
    @EnvironmentObject var budgetManager: BudgetManager
    @State var budgetfb = BudgetFB()
    @State private var isExpanded = false

    var body: some View {
        
        let nonEmptyPeriods = budgetManager.historicalPeriods.filter {
            !$0.incomes.isEmpty || !$0.fixedExpenses.isEmpty || !$0.variableExpenses.isEmpty
        }
        let emptyPeriods = budgetManager.historicalPeriods.filter {
            $0.incomes.isEmpty && $0.fixedExpenses.isEmpty && $0.variableExpenses.isEmpty
        }
        
        NavigationView {
            List {
                Section {
                    PeriodRowView(period: budgetManager.currentPeriod, isCurrent: true)
                            .listRowInsets(EdgeInsets(top: 10, leading: 4, bottom: 8, trailing: 4))
                } header: {
                    Text("Current Period")
                        .font(.title2)
                        .textCase(nil)
                        .padding(.leading, -10)
                }
                
                if !nonEmptyPeriods.isEmpty {
                    Section {
                        ForEach(nonEmptyPeriods.reversed()) { period in
                            PeriodRowView(period: period, isCurrent: false)
                                .listRowInsets(EdgeInsets(top: 0, leading: 4, bottom: 8, trailing: 4))
                        }
                        .onDelete { offsets in
                            budgetfb.deleteHistoricalPeriod(at: offsets, from: &budgetManager.historicalPeriods)
                        }
                        .listRowSeparator(.hidden)
                    } header: {
                        Text("Historical Periods")
                            .font(.title2)
                            .textCase(nil)
                            .padding(.leading, -10)
                    }
                    .padding(.bottom, 10)
                } else {
                    Text("You have no historical periods right now.")
                }

                if !emptyPeriods.isEmpty {
                    Section {
                        Button(action: {
                            withAnimation {
                                isExpanded.toggle()
                            }
                        }) {
                            HStack {
                                Text("Empty Periods")
                                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            }
                        }
                    }
                }
                if isExpanded {
                    Section {
                        ForEach(emptyPeriods.reversed()) { period in
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
                            .listRowInsets(EdgeInsets(top: 0, leading: 4, bottom: 8, trailing: 4))
                            .padding()
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 245/255, green: 247/255, blue: 245/255), // Light gray
                                        Color(red: 240/255, green: 242/255, blue: 240/255)  // Slightly darker gray
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
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
                        }
                        .onDelete { offsets in
                            budgetfb.deleteHistoricalPeriod(at: offsets, from: &budgetManager.historicalPeriods)
                        }
                    } header: {
                        Text("Empty Periods")
                            .font(.title2)
                            .textCase(nil)
                            .padding(.leading, -10)
                    }
                    .padding(.bottom, 10)
                }
            }
            .scrollContentBackground(.hidden)
            .onAppear {
                Task {
                    await budgetfb.loadHistoricalPeriods()
                }
            }
        }
        .task {
            await budgetManager.loadData()
        }
    }
}

struct OverviewTabView_Previews: PreviewProvider {
    static var previews: some View {
        OverviewTabView()
            .environmentObject(BudgetManager())
    }
}
