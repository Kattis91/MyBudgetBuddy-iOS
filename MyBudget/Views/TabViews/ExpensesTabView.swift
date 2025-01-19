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
   
    @State private var selectedView: ExpenseViewType = .fixed
    
    @State var budgetfb = BudgetFB()
    
    @State var showSettings = false

    var body: some View {
        
        NavigationStack {
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
                        selectedCategory: "",
                        totalExpenses: $budgetfb.totalExpenses,
                        expenseList: $budgetfb.fixedExpenseList,
                        budgetfb: budgetfb
                    )
                    .id(showSettings)
                } else {
                    ExpensesView(
                        viewtype: .variable,
                        selectedCategory: "",
                        totalExpenses: $budgetfb.totalExpenses,
                        expenseList: $budgetfb.variableExpenseList,
                        budgetfb: budgetfb
                    )
                    .id(showSettings)
                }
            }
            .task {
                await budgetfb.loadExpenseData(isfixed: true)
                await budgetfb.loadExpenseData(isfixed: false)// Ensure data is loaded when the view appears
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        showSettings.toggle()
                    }) {
                        Label("Open Settings", systemImage: "gearshape")
                            .font(.title2)
                            .foregroundColor(.purple)
                    }
                    .padding()
                }
            }
        }
        .sheet(isPresented: $showSettings, onDismiss: {
            Task {
                await budgetfb.loadExpenseData(isfixed: true)
                await budgetfb.loadExpenseData(isfixed: false)
            }
        }) {
            SettingsView(budgetfb: budgetfb)
        }
    }
}

#Preview {
    ExpensesTabView(budgetfb: BudgetFB())
}
