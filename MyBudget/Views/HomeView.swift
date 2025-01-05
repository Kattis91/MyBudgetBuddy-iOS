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
    
    var body: some View {
        
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
        .onAppear {
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
            }
        }
        .task {
            // Load data when view appears
            await budgetManager.loadData()
        }
        .accentColor(Color("TextColor"))
    }
    
}

#Preview {
    HomeView()
        .environmentObject(BudgetManager())
}
