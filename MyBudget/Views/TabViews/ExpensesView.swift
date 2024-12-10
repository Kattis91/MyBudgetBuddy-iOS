//
//  ExpensesView.swift
//  MyBudget
//
//  Created by Katya Durneva Svedmark on 2024-12-09.
//

import SwiftUI

struct ExpensesView: View {
    
    @State private var categories: [String]
    @State private var selectedCategory: String
    @State private var newCategory: String = ""
    
    @State private var expenseAmount: String = ""
    @State var errorMessage = ""
    
    @Binding var totalExpenses: Double
    @Binding var expenseList: [Expense]
    
    // Custom initializer to avoid private issues
    init(categories: [String], selectedCategory: String, expenseList: Binding<[Expense]>, totalExpenses: Binding<Double>) {
        self.categories = categories
        self._selectedCategory = State(initialValue: selectedCategory)
        self._expenseList = expenseList
        self._totalExpenses = totalExpenses
    }
    
    var body: some View {
        
        HStack {
            CustomTextFieldView(placeholder: "Expense amount", text: $expenseAmount, isSecure: false, onChange: {
                errorMessage = ""
            })
            
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
                CustomTextFieldView(placeholder: "New category", text: $newCategory, isSecure: false)
                    .padding(.top, 11)
                
                Button(action: {
                    if !newCategory.isEmpty {
                        categories.append(newCategory)
                        selectedCategory = newCategory
                        newCategory = ""
                    }
                }) {
                    ButtonView(buttontext: "Add")
                }
            }
        }
        
        Button(action: {
            if let expense = Double(expenseAmount) {
                if expense > 0.00 {
                    let newExpense = Expense(amount: expense, category: selectedCategory)
                    expenseList.append(newExpense)
                    totalExpenses += expense
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
        
        List {
            ForEach(expenseList) { expense in
                HStack {
                    Text(expense.category)
                    Spacer()
                    Text("- \(expense.amount, specifier: "%.2f")")
                }
            }
            .onDelete(perform: deleteItems)
        }
    }
    
    func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                totalExpenses -= expenseList[index].amount
            }
        }
        expenseList.remove(atOffsets: offsets)
    }
}

#Preview {
    ExpensesView(
        categories: ["Rent", "Water", "Electricity"],
        selectedCategory: "Rent",
        expenseList: .constant([]),
        totalExpenses: .constant(100.0)
    )
}
