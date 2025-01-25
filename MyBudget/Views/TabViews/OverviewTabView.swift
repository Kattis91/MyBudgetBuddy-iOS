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

    var body: some View {
        
        let nonEmptyPeriods = budgetManager.historicalPeriods.filter {
            !$0.incomes.isEmpty || !$0.fixedExpenses.isEmpty || !$0.variableExpenses.isEmpty
        }
        let emptyPeriods = budgetManager.historicalPeriods.filter {
            $0.incomes.isEmpty && $0.fixedExpenses.isEmpty && $0.variableExpenses.isEmpty
        }
        
        NavigationView {
            List {
                Section("Current Period") {
                    PeriodRowView(period: budgetManager.currentPeriod, isCurrent: true)
                            .listRowInsets(EdgeInsets(top: 5, leading: 4, bottom: 5, trailing: 4))
                            
                }
                
                if !nonEmptyPeriods.isEmpty {
                    Section("Historical Periods") {
                        ForEach(nonEmptyPeriods.reversed()) { period in
                            PeriodRowView(period: period, isCurrent: false)
                                .listRowInsets(EdgeInsets(top: 0, leading: 4, bottom: 8, trailing: 4))
                        }
                        .onDelete { offsets in
                            budgetfb.deleteHistoricalPeriod(at: offsets, from: budgetManager.historicalPeriods)
                        }
                        .listRowSeparator(.hidden)
                    }
                    .padding(.bottom, 8)
                }

                if !emptyPeriods.isEmpty {
                    Section("Empty Periods") {
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
                        }
                        .onDelete { offsets in
                            budgetfb.deleteHistoricalPeriod(at: offsets, from: budgetManager.historicalPeriods)
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .onAppear {
                Task {
                    await budgetfb.loadHistoricalPeriods()
                }
            }
            .navigationTitle("Budget Periods")
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
