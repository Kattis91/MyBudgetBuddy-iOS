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
            VStack(spacing: 0) {
                PeriodRowView(period: budgetManager.currentPeriod, isCurrent: true)
                    .padding(.horizontal, 10)
                    .padding(.top, 20)
                    .padding(.bottom, 8)
                
                if !nonEmptyPeriods.isEmpty {
                    HStack {
                        Text("Historical Periods")
                            .font(.title2)
                            .textCase(nil)
                            .padding(.leading, 10)
                            .foregroundColor(Color("PrimaryTextColor"))
                        Spacer()
                    }
                    .padding(.vertical, 20)
                    
                    HStack {
                        Image(systemName: "arrow.left.to.line")
                            .font(.caption)
                        Text("Swipe left to delete periods")
                            .font(.caption)
                    }
                    .foregroundStyle(Color("PrimaryTextColor"))
                    .padding(.horizontal)
                    .padding(.bottom, 10)
                    
                    // Historical Periods List
                    List {
                        ForEach(nonEmptyPeriods.reversed()) { period in
                            PeriodRowView(period: period, isCurrent: false)
                                .listRowInsets(EdgeInsets())
                                .padding(.horizontal, 10)
                                .padding(.bottom, 15)
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
                        .listRowBackground(Color.clear)
                    }
                    .listStyle(PlainListStyle())
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                } else {
                    Text("You have no historical periods right now.")
                        .padding(.top, 20)
                }
            }
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
