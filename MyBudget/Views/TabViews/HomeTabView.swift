//
//  HomeTabView.swift
//  MyBudget
//
//  Created by Katya Durneva Svedmark on 2024-12-05.
//

import SwiftUI

struct HomeTabView: View {
    
    @State var showingNewPeriod: Bool = false
    
    var budgetfb = BudgetFB()
    
    var body: some View {
        
        NavigationStack {
            VStack {
                Text("Total Income: \(budgetfb.totalIncome, specifier: "%.2f")")
                    .font(.title)
                    .padding()
                
                Text("Total Expense: \(budgetfb.totalExpenses, specifier: "%.2f")")
                    .font(.title)
                
                Text("Total Outcome: \(budgetfb.totalIncome - budgetfb.totalExpenses, specifier: "%.2f")")
                    .font(.title)
                    .padding()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    
                    Button(action: {
                        budgetfb.userLogout()
                    }) {
                        Text("Sign out")
                    }
                }
            }
        }
    }
    
}

#Preview {
    HomeTabView()
}
