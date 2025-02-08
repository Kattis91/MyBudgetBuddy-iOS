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
