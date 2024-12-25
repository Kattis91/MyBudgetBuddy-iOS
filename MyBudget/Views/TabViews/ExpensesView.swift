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
    
    @State var categories: [String]
    @State var selectedCategory: String
    @State var newCategory: String = ""
    
    @State var expenseAmount: String = ""
    @State var errorMessage = ""
    
    @Binding var totalExpenses: Double
    @Binding var expenseList: [Expense]
    
    // @ObservedObject var expenseData: ExpenseData
    
    @State var budgetfb = BudgetFB()
    
   
    
    // Custom initializer to avoid private issues
    /*
    init(categories: [String], selectedCategory: String, expenseList: Binding<[Expense]>, totalExpenses: Binding<Double>) {
        self.categories = categories
        self._selectedCategory = State(initialValue: selectedCategory)
        self._expenseList = expenseList
        self._totalExpenses = totalExpenses
        self._expenseData = .init(initialValue: ExpenseData())
    }
    */
    var body: some View {
        
        HStack {
            CustomTextFieldView(placeholder: "Expense amount", text: $expenseAmount, isSecure: false, onChange: {
                errorMessage = ""
            }, trailingPadding: 5, systemName: "minus.circle")
            
            Picker("Category", selection: $selectedCategory) {
                ForEach(categories, id: \.self) { category in
                    Text(category)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .padding(.bottom)
        }
        
        if selectedCategory == "Something else?" {
            HStack {
                CustomTextFieldView(placeholder: "New category", text: $newCategory, isSecure: false, trailingPadding: 0)
                    .padding(.top, 11)
                
                Button(action: {
                    if !newCategory.isEmpty {
                        categories.append(newCategory)
                        selectedCategory = newCategory
                        newCategory = ""
                    }
                }) {
                    ButtonView(buttontext: "Add", maxWidth: 80, leadingPadding: 10)
                }
            }
        }
        
        Button(action: {
            if let expense = Double(expenseAmount) {
                if expense > 0.00 {
                    budgetfb.saveExpenseData(amount: expense, category: selectedCategory, isfixed: ( viewtype == .fixed )) // Pass the validated Double to saveIncomeData
                    expenseAmount = ""
                } else {
                    errorMessage = "Amount must be greater than zero."
                }
            } else {
                errorMessage = "Amount must be a number."
            }
        }) {
            ButtonView(buttontext: "Add expense")
        }
        
        ErrorMessageView(errorMessage: errorMessage, height: 20)
        
        if viewtype == .fixed {
            CustomListView(
                items: budgetfb.fixedExpenseList,
                deleteAction: deleteFixedExpense,
                itemContent: { expense in
                    (category: expense.category, amount: expense.amount)
                }, showNegativeAmount: true
            )
        } else {
            CustomListView(
                items: budgetfb.variableExpenseList,
                deleteAction: deleteVariableExpense,
                itemContent: { expense in
                    (category: expense.category, amount: expense.amount)
                }, showNegativeAmount: true
            )
        }
    }
    
    // Bridge function for Fixed
    private func deleteFixedExpense(at offsets: IndexSet) {
        budgetfb.deleteExpense(from: "fixed", at: offsets)
    }
    
    // Bridge function for Variable
    private func deleteVariableExpense(at offsets: IndexSet) {
        budgetfb.deleteExpense(from: "variable", at: offsets)
    }
}

#Preview {
    ExpensesView(
        viewtype: .fixed, categories: ["Rent", "Water", "Electricity"],
        selectedCategory: "Rent",
        totalExpenses: .constant(100.0), expenseList: .constant([]),
        budgetfb: BudgetFB()
    )
}
