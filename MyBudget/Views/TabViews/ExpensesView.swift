//
//  ExpensesView.swift
//  MyBudget
//
//  Created by Katya Durneva Svedmark on 2024-12-09.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct ExpensesView: View {
    
    var viewtype : ExpenseViewType
    
    @State private var categories: [String] = []
    @State var selectedCategory: String
    @State var newCategory: String = ""
    
    @State var expenseAmount: String = ""
    @Binding var errorMessage: String
    
    @Binding var totalExpenses: Double
    @Binding var expenseList: [Expense]
    
    @State var showNewCategoryField = false
    
    @State var budgetfb = BudgetFB()
   
    var body: some View {
        
        VStack {
            CustomTextFieldView(placeholder: String(localized: "Expense amount"), text: $expenseAmount, isSecure: false, onChange: {
                errorMessage = ""
            }, leadingPadding: 33, trailingPadding: 33, systemName: "minus.circle", maxLength: 15)
            
            if showNewCategoryField {
                HStack {
                    CustomTextFieldView(placeholder: "New category", text: $newCategory, isSecure: false, leadingPadding: 33, systemName: "tag", maxLength: 30)
                    Button(action: {
                        showNewCategoryField = false
                        selectedCategory = ""
                        newCategory = ""
                    }) {
                        Image(systemName: "arrow.uturn.backward")
                            .foregroundColor(.blue)
                            .padding(.trailing, 33)
                            .padding(.bottom, 8)
                    }
                }
                .padding(.top, 5)
            } else {
                Menu {
                    ForEach(categories, id: \.self) { category in
                        Button(category) {
                            selectedCategory = category
                        }
                    }
                    Button("+ Add new category") {
                        selectedCategory = "new"
                        showNewCategoryField = true
                    }
                } label: {
                    HStack {
                        Text(selectedCategory.isEmpty ? String(localized: "Choose Category") : selectedCategory)
                            .foregroundColor(selectedCategory.isEmpty ? .black.opacity(0.5) : .black)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 245/255, green: 247/255, blue: 245/255), // Light gray
                                Color(red: 240/255, green: 242/255, blue: 240/255)  // Slightly darker gray
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(18)
                    .shadow(
                        color: .black.opacity(0.25),
                        radius: 1,
                        x: -2,
                        y: 4
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.4), lineWidth: 0.8)
                    )
                }
                .padding(.bottom, 3)
                .padding(.horizontal, 31)
            }
        }
        
        ErrorMessageView(errorMessage: errorMessage, height: 15)
    
        Button(action: {
            if let expense = Double(expenseAmount) {
                if expense > 0.00 {
                    if showNewCategoryField {
                        if !newCategory.isEmpty {
                            Task {
                                let categoryType: CategoryType = viewtype == .fixed ? .fixedExpense : .variableExpense
                                let success = await budgetfb.addCategory(name: newCategory, type: categoryType)
                                if success {
                                    await MainActor.run {
                                        categories.append(newCategory)
                                        let categoryToUse = newCategory
                                        expenseAmount = ""
                                        budgetfb.saveExpenseData(amount: expense, category: categoryToUse, isfixed: ( viewtype == .fixed ))
                                        showNewCategoryField = false
                                        selectedCategory = ""
                                    }
                                } else {
                                    await MainActor.run {
                                        errorMessage = String(localized: "Failed to add category")
                                    }
                                }
                            }
                        } else {
                            errorMessage = String(localized: "Please add a category")
                        }
                    } else {
                        if !selectedCategory.isEmpty {
                            let categoryToUse = selectedCategory
                            expenseAmount = ""
                            budgetfb.saveExpenseData(amount: expense, category: categoryToUse, isfixed: ( viewtype == .fixed )) 
                            selectedCategory = ""
                        } else {
                            errorMessage = String(localized: "Please select a category.")
                        }
                    }
                } else {
                    errorMessage = String(localized: "Amount must be greater than zero.")
                }
            } else {
                errorMessage = String(localized: "Amount must be a number.")
            }
        }) {
            ButtonView(buttontext: String(localized: "Add expense"), expenseButton: true, height: 41, leadingPadding: 33, trailingPadding: 33, topPadding: 5)
        }
        .task {
            await loadCategories()
        }
        
        if viewtype == .fixed {
            CustomListView(
                items: budgetfb.fixedExpenseList,
                deleteAction: deleteFixedExpense,
                itemContent: { expense in
                    (category: expense.category, amount: expense.amount, date: nil)
                }, isCurrent: true,
                showNegativeAmount: true,
                alignAmountInMiddle: false,
                isInvoice: false,
                onMarkProcessed: nil
            )
        } else {
            CustomListView(
                items: budgetfb.variableExpenseList,
                deleteAction: deleteVariableExpense,
                itemContent: { expense in
                    (category: expense.category, amount: expense.amount, date: nil)
                }, isCurrent: true,
                showNegativeAmount: true,
                alignAmountInMiddle: false,
                isInvoice: false,
                onMarkProcessed: nil
            )
        }
    }
    
    private func loadCategories() async {
        let categoryType: CategoryType = viewtype == .fixed ? .fixedExpense : .variableExpense
        let loadedCategories = await budgetfb.loadCategories(type: categoryType)
        categories = loadedCategories
    }
    
    // Bridge function for Fixed
    private func deleteFixedExpense(at offsets: IndexSet) {
        budgetfb.deleteExpense(isfixed: true, from: "fixed", at: offsets)
    }
    
    // Bridge function for Variable
    private func deleteVariableExpense(at offsets: IndexSet) {
        budgetfb.deleteExpense(isfixed: false, from: "variable", at: offsets)
    }
}

#Preview {
    ExpensesView(
        viewtype: .fixed, 
        selectedCategory: "Rent",
        errorMessage: .constant(""), totalExpenses: .constant(100.0), expenseList: .constant([]),
        budgetfb: BudgetFB()
    )
}
