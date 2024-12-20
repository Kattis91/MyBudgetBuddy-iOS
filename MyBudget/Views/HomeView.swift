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
        appearance.backgroundColor = UIColor(Color("TabColor"))// Ange bakgrundsfärgen här
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    @State var budgetfb = BudgetFB()
    @StateObject private var incomeData = IncomeData()
    @StateObject private var expenseData = ExpenseData()
    
    var body: some View {
        
        VStack {
            
            TabView {
                Tab("Home", systemImage: "house") {
                    HomeTabView(incomeData: incomeData, expenseData: expenseData)
                }
                
                Tab("Incomes", systemImage: "plus.circle") {
                    IncomesTabView(incomeData: incomeData)
                }
                
                Tab("Expenses", systemImage: "minus.circle") {
                    ExpensesTabView(expenseData: expenseData)
                }
                
                Tab("Overview", systemImage: "chart.bar") {
                    OverviewTabView()
                }
                
            }
        }
    }
    
}

#Preview {
    HomeView()
}
