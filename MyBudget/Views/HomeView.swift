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
    @State private var hasCurrentPeriod = false
    @State var showNewPeriodSheet = false
    
    var body: some View {
        
        Group {
            if isCheckingPeriods {
                ProgressView()
            } else {
                if hasExistingPeriods {
                    if hasCurrentPeriod {
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
                        VStack(spacing: 20) {
                            Image("Save")
                                .resizable()
                                .frame(width: 180, height: 180)
                                .padding(.bottom, 30)
                            
                            Text("Your last budget period has ended")
                                .font(.title)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                            
                            Text("Start a new period to continue tracking your budget")
                                .multilineTextAlignment(.center)
                            
                            Button(action: {
                                showNewPeriodSheet = true
                            }) {
                                ButtonView(buttontext: "Start New Period", maxWidth: 180)
                            }
                        }
                        .padding()
                    }
                } else {
                    FirstTimePeriodView(onPeriodCreated: {
                            hasExistingPeriods = true
                            hasCurrentPeriod = true
                            loadInitialData()
                        })
                    }
                }
            }
            .sheet(isPresented: $showNewPeriodSheet) {
                NewBudgetPeriodView(
                    isPresented: $showNewPeriodSheet,
                    onSuccess: {
                        hasCurrentPeriod = true
                        loadInitialData()
                    }
                )
            }
            .onAppear {
                checkInitialState()
        }
    }
    
    private func checkInitialState() {
        isCheckingPeriods = true
        
        // First check if any periods exist (current or historical)
        budgetfb.checkForAnyBudgetPeriod { exists in
            hasExistingPeriods = exists
            
            if exists {
                // Then check if there's a current period
                budgetfb.loadCurrentBudgetPeriod { loadedPeriod in
                    hasCurrentPeriod = loadedPeriod != nil
                    
                    if loadedPeriod != nil {
                        loadInitialData()
                    }
                    
                    isCheckingPeriods = false
                }
            } else {
                isCheckingPeriods = false
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
