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
    
    @ObservedObject var expenseData: ExpenseData
    
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
                    /*
                    expenseData.addExpense(amount: expense, category: selectedCategory, isfixed: ( viewtype == .fixed ))
                    */
                    budgetfb.saveExpenseData(amount: expense, category: selectedCategory, isfixed: ( viewtype == .fixed )) // Pass the validated Double to saveIncomeData
                    expenseAmount = ""
                    Task {
                        await budgetfb.loadExpenseData(expenseData: expenseData)
                    }
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
            List {
                ForEach(expenseData.fixedExpenseList) { expense in
                    HStack {
                        Text(expense.category)
                        Spacer()
                        Text("- \(expense.amount, specifier: "%.2f")")
                    }
                    .padding()
                }
                .onDelete { offsets in
                    deleteExpense(from: "fixed", at: offsets, expenseData: expenseData)
                }
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color("TabColor"))
                )
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
            }
            .scrollContentBackground(.hidden)
            .padding(.horizontal, 10)
        } else {
            List {
                ForEach(expenseData.variableExpenseList) { expense in
                    HStack {
                        Text(expense.category)
                        Spacer()
                        Text("- \(expense.amount, specifier: "%.2f")")
                    }
                    .padding()
                }
                .onDelete { offsets in
                    deleteExpense(from: "variable", at: offsets, expenseData: expenseData)
                }
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color("TabColor"))
                )
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
            }
            .scrollContentBackground(.hidden)
            .padding(.horizontal, 10)
        }
    }
    
    func deleteExpense(from listType: String, at offsets: IndexSet, expenseData: ExpenseData) {
        let userId = Auth.auth().currentUser?.uid
        guard let userId else { return }

        var ref: DatabaseReference!
        ref = Database.database().reference()

        var expenseList: [Expense] // Common array for handling expenses

        // Determine which list to use based on `listType`
        switch listType {
        case "fixed":
            expenseList = expenseData.fixedExpenseList
        case "variable":
            expenseList = expenseData.variableExpenseList
        default:
            print("Invalid list type")
            return
        }

        for offset in offsets {
            let expenseItem = expenseList[offset]
            print("DELETE \(offset)")
            print(expenseItem.id)
            print(expenseItem.category)
            ref.child("expenses").child(userId).child(expenseItem.id).removeValue()
        }

        // Update local data
        if listType == "fixed" {
            expenseData.fixedExpenseList.remove(atOffsets: offsets)
        } else if listType == "variable" {
            expenseData.variableExpenseList.remove(atOffsets: offsets)
        }

        // Recalculate total expenses
        expenseData.totalExpenses = (expenseData.fixedExpenseList + expenseData.variableExpenseList)
            .reduce(0.0) { $0 + $1.amount }
    }

}

#Preview {
    ExpensesView(
        viewtype: .fixed, categories: ["Rent", "Water", "Electricity"],
        selectedCategory: "Rent",
        totalExpenses: .constant(100.0), expenseList: .constant([]),
        expenseData: ExpenseData()
    )
}
