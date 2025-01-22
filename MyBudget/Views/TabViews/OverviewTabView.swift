//
//  OverviewTabView.swift
//  MyBudget
//
//  Created by Katya Durneva Svedmark on 2024-12-05.
//

import SwiftUI

struct OverviewTabView: View {
    @State var showingNewPeriod = false
    @EnvironmentObject var budgetManager: BudgetManager
    @State var budgetfb = BudgetFB()

    
    var body: some View {
        NavigationView {
            List {
                Section("Current Period") {
                    PeriodRowView(period: budgetManager.currentPeriod, isCurrent: true)
                }
                
                if !budgetManager.historicalPeriods.isEmpty {
                    Section("Historical Periods") {
                        ForEach(budgetManager.historicalPeriods.reversed()) { period in
                            PeriodRowView(period: period, isCurrent: false)
                        }
                        .onDelete { offsets in
                            budgetfb.deleteHistoricalPeriod(at: offsets, from: budgetManager.historicalPeriods)
                        }
                    }
                }
            }
            .onAppear {
                Task {
                    await budgetfb.loadHistoricalPeriods()
                }
            }
            .navigationTitle("Budget Periods")
            .toolbar {
                Button("New Period") {
                    showingNewPeriod = true
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
