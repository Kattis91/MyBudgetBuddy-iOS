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
                            .listRowInsets(EdgeInsets(top: 10, leading: 10, bottom: 8, trailing: 10))
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
                                .listRowInsets(EdgeInsets(top: 0, leading: 10, bottom: 8, trailing: 10))
                        }
                        .onDelete { offsets in
                            Task {
                                // Convert offsets from filtered array to original array indices
                                let filteredPeriods = budgetManager.historicalPeriods.filter {
                                    !$0.incomes.isEmpty || !$0.fixedExpenses.isEmpty || !$0.variableExpenses.isEmpty
                                }
                                // Get the IDs of periods to delete
                                let periodsToDelete = offsets.map { filteredPeriods[$0] }
                                // Find corresponding indices in the original array
                                let originalIndices = IndexSet(periodsToDelete.compactMap { period in
                                    budgetManager.historicalPeriods.firstIndex(where: { $0.id == period.id })
                                })
                                await budgetfb.deleteHistoricalPeriod(at: originalIndices, from: budgetManager.historicalPeriods)
                            }
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
            .listStyle(PlainListStyle())
            .background(Color.clear)
            .onReceive(NotificationCenter.default.publisher(for: .init("HistoricalPeriodsUpdated"))) { notification in
                if let updatedPeriods = notification.object as? [BudgetPeriod] {
                    budgetManager.historicalPeriods = updatedPeriods
                }
            }
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
