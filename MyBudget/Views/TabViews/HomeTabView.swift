//
//  HomeTabView.swift
//  MyBudget
//
//  Created by Katya Durneva Svedmark on 2024-12-05.
//

import SwiftUI

struct HomeTabView: View {
    @ObservedObject var incomeData: IncomeData
    @ObservedObject var expenseData: ExpenseData
    
    @State var budgetfb = BudgetFB()
    
    var body: some View {
        
        NavigationStack {
            VStack {
                Text("Here is a home page")
                Text("Total Income: \(incomeData.totalIncome, specifier: "%.2f")")
                    .font(.title)
                    .padding()
                
                Text("Total Expense: \(expenseData.totalExpenses, specifier: "%.2f")")
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
    HomeTabView(incomeData: IncomeData(), expenseData: ExpenseData())
}
