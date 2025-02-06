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
    @EnvironmentObject var budgetManager: BudgetManager
    
    @State var showSettings = false
    @State private var refreshTrigger = UUID()

    var body: some View {
        
        NavigationStack {
            VStack {
                VStack {
                    Text("Current Period:")
                        .font(.headline)
                        .padding(.bottom, 10)
                    Text(DateUtils.formattedDateRange(
                       startDate: budgetManager.currentPeriod.startDate,
                       endDate: budgetManager.currentPeriod.endDate
                   ))
                }
                .padding()
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [.backgroundTintLight, .backgroundTintDark]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(16)
                .shadow(
                    color: .black.opacity(0.3),
                    radius: 1,
                    x: 0,
                    y: 3
                )
                // Add subtle border for more definition
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.3), lineWidth: 0.5)
                )
                
                VStack {
                    Text("Total expenses:")
                    Text("\(budgetfb.totalExpenses,  specifier: "%.2f")")
                }
                .font(.title)
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
                    .id(refreshTrigger)
                } else {
                    ExpensesView(
                        viewtype: .variable,
                        selectedCategory: "",
                        totalExpenses: $budgetfb.totalExpenses,
                        expenseList: $budgetfb.variableExpenseList,
                        budgetfb: budgetfb
                    )
                    .id(refreshTrigger)
                }
            }
            .task {
                await budgetfb.loadExpenseData(isfixed: true)
                await budgetfb.loadExpenseData(isfixed: false)// Ensure data is loaded when the view appears
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    CustomSettingsMenu(
                        budgetfb: budgetfb,
                        onCategoriesUpdate: {
                            // Load both fixed and variable expenses after category updates
                            await budgetfb.loadExpenseData(isfixed: true)
                            await budgetfb.loadExpenseData(isfixed: false)
                            _ = await budgetfb.loadCategories(type: .fixedExpense)
                            _ = await budgetfb.loadCategories(type: .variableExpense)
                            await MainActor.run {
                                refreshTrigger = UUID() // Force view refresh
                            }
                        }
                    )
                }
            }
        }
    }
}

#Preview {
    ExpensesTabView(budgetfb: BudgetFB())
        .environmentObject(BudgetManager())
}
