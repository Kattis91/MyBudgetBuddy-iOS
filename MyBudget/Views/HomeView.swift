//
//  HomeView.swift
//  MyBudget
//
//  Created by Katya Durneva Svedmark on 2024-12-01.
//

import SwiftUI
import FirebaseAuth

struct HomeView: View {
    
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        // Set the background color of the tab bar
        appearance.backgroundColor = UIColor(Color("TabColor"))
        
        // Set the appearance for inactive tabs
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(Color("ButtonsBackground"))
        
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor(Color("ButtonsBackground"))
        ]
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    @EnvironmentObject var budgetManager: BudgetManager
    @State var budgetfb = BudgetFB()
    @State private var hasExistingPeriods = false
    @State private var isCheckingPeriods = true
    
    var body: some View {
        
        Group {
            if isCheckingPeriods {
                ProgressView()
            } else {
                if hasExistingPeriods {
                    VStack {
                        TabView {
                            Tab("Home", systemImage: "house") {
                                HomeTabView(budgetfb: budgetfb)
                            }
                            
                            Tab("Incomes", systemImage: "plus.circle") {
                                IncomesTabView(budgetfb: budgetfb)
                            }
                            
                            Tab("Expenses", systemImage: "minus.circle") {
                                ExpensesTabView(budgetfb: budgetfb)
                            }
                            
                            Tab("Overview", systemImage: "chart.bar") {
                                OverviewTabView()
                            }
                            
                        }
                    }
                    .onReceive(NotificationCenter.default.publisher(for: .periodUpdated)) { _ in
                        Task {
                            await budgetfb.loadIncomeData()
                            await budgetfb.loadExpenseData(isfixed: true)
                            await budgetfb.loadExpenseData(isfixed: false)
                        }
                    }
                    .accentColor(Color("TextColor"))
                } else {
                    FirstTimePeriodView(onPeriodCreated: {
                            hasExistingPeriods = true
                            loadInitialData()
                        })
                    }
                }
            }
            .onAppear {
                checkInitialState()
        }
    }
    
    private func checkInitialState() {
        budgetfb.checkForAnyBudgetPeriod { exists in
            hasExistingPeriods = exists
            isCheckingPeriods = false
            
            if exists {
                loadInitialData()
            }
        }
    }
    
    private func loadInitialData() {
        budgetfb.loadCurrentBudgetPeriod { loadedPeriod in
            if let loadedPeriod = loadedPeriod {
                DispatchQueue.main.async {
                    budgetManager.currentPeriod = loadedPeriod
                }
            }
        }
        
        Task {
            await budgetfb.loadIncomeData()
            await budgetfb.loadExpenseData(isfixed: true)
            await budgetfb.loadExpenseData(isfixed: false)
            await budgetManager.loadData()
        }
    }
    
}

#Preview {
    HomeView()
        .environmentObject(BudgetManager())
}
