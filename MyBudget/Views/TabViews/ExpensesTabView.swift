//
//  ExpensesTabView.swift
//  MyBudget
//
//  Created by Katya Durneva Svedmark on 2024-12-05.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct ExpensesTabView: View {
    
   // @ObservedObject var expenseData: ExpenseData
    @State private var selectedView: ExpenseViewType = .fixed
    
    @State var budgetfb = BudgetFB()

    var body: some View {
        
        VStack {
            
            Text("Total expenses: \(budgetfb.totalExpenses,  specifier: "%.2f")")
                .font(.largeTitle)
                .bold()
                .padding()
            
            HStack {
                Button(action: {
                    selectedView = .fixed
                }) {
                    Text("Fixed expenses")
                        .padding(.vertical, 5)
                        .padding(.horizontal, 10)
                        .background(selectedView == .fixed ? Color.buttonsBackground : Color.white)
                        .cornerRadius(10)
                        .padding(.leading, 33)
                        .foregroundStyle(selectedView == .fixed ? Color.white : Color("TextColor"))
                }
                
                Spacer()
                
                Button(action: {
                    selectedView = .variable
                }) {
                    Text("Variable expenses")
                        .padding(.vertical, 5)
                        .padding(.horizontal, 10)
                        .background(selectedView == .variable ? Color.buttonsBackground : Color.white)
                        .cornerRadius(10)
                        .padding(.trailing, 33)
                        .foregroundStyle(selectedView == .variable ? Color.white : Color("TextColor"))
                }
            }
            .padding(.bottom, 10)
            
            // Display the selected view
            if selectedView == .fixed {
                ExpensesView(
                    viewtype: .fixed,
                    categories: ["Rent", "Water", "Heat", "Electricity", "Insurance", "Mobile", "Netflix", "WiFi"],
                    selectedCategory: "",
                    totalExpenses: $budgetfb.totalExpenses,
                    expenseList: $budgetfb.fixedExpenseList,
                    budgetfb: budgetfb
                )
            } else {
                ExpensesView(
                    viewtype: .variable,
                    categories: ["Groceries","Dining Out",  "Shopping", "Entertainment", "Transport", "Savings"],
                    selectedCategory: "",
                    totalExpenses: $budgetfb.totalExpenses,
                    expenseList: $budgetfb.variableExpenseList,
                    budgetfb: budgetfb
                )
            }
        }
        .task {
            await budgetfb.loadExpenseData() // Ensure data is loaded when the view appears
        }
    }
}

#Preview {
    ExpensesTabView(budgetfb: BudgetFB())
}
