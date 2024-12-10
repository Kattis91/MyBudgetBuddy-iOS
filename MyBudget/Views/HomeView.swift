//
//  HomeView.swift
//  MyBudget
//
//  Created by Katya Durneva Svedmark on 2024-12-01.
//

import SwiftUI
import FirebaseAuth

struct HomeView: View {
    
    @State var budgetfb = BudgetFB()
    @StateObject private var incomeData = IncomeData()
    
    var body: some View {
        
        VStack {
            
            TabView {
                Tab("Home", systemImage: "house") {
                    HomeTabView(incomeData: incomeData)
                }
                
                Tab("Incomes", systemImage: "plus.circle") {
                    IncomesTabView(incomeData: incomeData)
                }
                
                Tab("Expenses", systemImage: "minus.circle") {
                    ExpensesTabView()
                }
                
                Tab("Overview", systemImage: "chart.bar") {
                    OverviewTabView()
                }
                
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.orange.opacity(0.2))
        
    }
}

#Preview {
    HomeView()
}
