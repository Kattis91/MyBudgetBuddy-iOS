//
//  ExpensesTabView.swift
//  MyBudget
//
//  Created by Katya Durneva Svedmark on 2024-12-05.
//

import SwiftUI

struct ExpensesTabView: View {
    
    @State private var categories: [String] = ["Rent", "Food", "Transport", "Water", "Heat", "Electricity", "Insuranse", "Mobile", "Netflix", "WiFi", "Savings", "Something else?"]
    @State private var selectedCategory: String = "Rent"
    @State private var newCategory: String = ""
    
    @State private var expenseAmount: String = ""
    @State private var totalExpenses: Double = 0.0
    
    @State private var expenseList: [Expense] = []
    
    
    var body: some View {
        
        Text("Total expenses: \(totalExpenses,  specifier: "%.2f")")
            .font(.largeTitle)
            .bold()
            .padding()
        
        HStack {
            CustomTextFieldView(placeholder: "Expense amount", text: $expenseAmount, isSecure: false)
            
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
                let newExpense = Expense(amount: expense, category: selectedCategory)
                expenseList.append(newExpense)
                expenseAmount = ""
            }
        }) {
            ButtonView(buttontext: "Add expense")
        }
        
        List {
            ForEach(expenseList) { expense in
                HStack {
                    Text(expense.category)
                    Spacer()
                    Text("- \(expense.amount, specifier: "%.2f")")
                }
            }
        }
    }
}

#Preview {
    ExpensesTabView()
}
