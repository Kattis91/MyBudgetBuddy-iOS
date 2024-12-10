//
//  ExpensesTabView.swift
//  MyBudget
//
//  Created by Katya Durneva Svedmark on 2024-12-05.
//

import SwiftUI

struct ExpensesTabView: View {
   
    @ObservedObject var expenseData: ExpenseData
    @State private var selectedView: ExpenseViewType = .fixed

    var body: some View {
        
        Text("Total expenses: \(expenseData.totalExpenses,  specifier: "%.2f")")
            .font(.largeTitle)
            .bold()
            .padding()
        
        HStack {
            Button(action: {
                selectedView = .fixed
            }) {
                Text("Fixed expenses")
                    .background(selectedView == .fixed ? Color.yellow : Color.white)
                    .padding(.horizontal, 24)
            }
            
            Spacer()
            
            Button(action: {
                selectedView = .variable
            }) {
                Text("Variable expenses")
                    .background(selectedView == .variable ? Color.yellow : Color.white)
                    .padding(.horizontal, 24)
            }
        }
        
        // Display the selected view
       if selectedView == .fixed {
           ExpensesView(
               categories: ["Rent", "Water", "Heat", "Electricity", "Insurance", "Mobile", "Netflix", "WiFi", "Something else?"],
               selectedCategory: "Rent",
               expenseList: $expenseData.fixedExpenseList,
               totalExpenses: $expenseData.totalExpenses
           )
       } else {
           ExpensesView(
               categories: ["Groceries","Dining Out",  "Shopping", "Entertainment", "Transport", "Savings", "Something else?"],
               selectedCategory: "Groceries",
               expenseList: $expenseData.variableExpenseList,
               totalExpenses: $expenseData.totalExpenses)
       }
    }
}

#Preview {
    ExpensesTabView(expenseData: ExpenseData())
}
