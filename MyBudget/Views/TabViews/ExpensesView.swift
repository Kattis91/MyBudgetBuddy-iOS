//
//  ExpensesView.swift
//  MyBudget
//
//  Created by Katya Durneva Svedmark on 2024-12-09.
//

import SwiftUI
import Firebase

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
                    expenseData.addExpense(amount: expense, category: selectedCategory, isfixed: ( viewtype == .fixed ))
                    saveExpenseData(amount: expense, category: selectedCategory, isfixed: ( viewtype == .fixed )) // Pass the validated Double to saveIncomeData
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
            .onDelete { offsets in expenseData.deleteExpense(at: offsets, isfixed: ( viewtype == .fixed ))
            }
        }
        .background(Color.background)
        .scrollContentBackground(.hidden)
    }
    
    func saveExpenseData(amount: Double, category: String, isfixed: Bool) {
        var ref: DatabaseReference!
        
        ref = Database.database().reference()
        
        let expenseEntry: [String: Any] = [
            "amount": amount,
            "category": category,
            "isfixed": isfixed
            ]
        
        ref.child("expenses").childByAutoId().child("expensedata").setValue(expenseEntry)
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
