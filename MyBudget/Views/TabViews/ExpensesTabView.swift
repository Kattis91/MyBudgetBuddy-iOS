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
    
    @ObservedObject var expenseData: ExpenseData
    @State private var selectedView: ExpenseViewType = .fixed

    var body: some View {
        
        VStack {
            
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
                    viewtype: .fixed,
                    categories: ["Rent", "Water", "Heat", "Electricity", "Insurance", "Mobile", "Netflix", "WiFi", "Something else?"],
                    selectedCategory: "Rent",
                    totalExpenses: $expenseData.totalExpenses,
                    expenseList: $expenseData.fixedExpenseList,
                    expenseData: expenseData
                )
            } else {
                ExpensesView(
                    viewtype: .variable,
                    categories: ["Groceries","Dining Out",  "Shopping", "Entertainment", "Transport", "Savings", "Something else?"],
                    selectedCategory: "Groceries",
                    totalExpenses: $expenseData.totalExpenses,
                    expenseList: $expenseData.variableExpenseList,
                    expenseData: expenseData
                )
            }
        }
        .task {
            await loadExpenseData() // Ensure data is loaded when the view appears
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.background)
    }
    
    func loadExpenseData() async {
        
        guard let userid = Auth.auth().currentUser?.uid else { return }
        
        var ref: DatabaseReference!
        
        ref = Database.database().reference()
        
        do {
            let expensedata = try await ref.child("expenses").child(userid).getData()
            print(expensedata.childrenCount)
            
            expenseData.variableExpenseList = []
            expenseData.fixedExpenseList = []
            
            for expenseitem in expensedata.children {
                let expensesnap = expenseitem as! DataSnapshot
                
                // Access the "income data" child
                guard let expenseDataDict = expensesnap.childSnapshot(forPath: "expensedata").value as? [String: Any]
                else {
                    print("Failed to get income data")
                    continue
                }
                
                print(expenseDataDict)
                
                let fetchedExpense = Expense(
                    amount: expenseDataDict["amount"] as? Double ?? 0.0,  // Default to 0.0 if not found
                    category: expenseDataDict["category"] as? String ?? "Unknown",
                    isfixed: expenseDataDict["isfixed"] as? Bool ?? false  // Default to "Unknown" if not found
                )
                
                if fetchedExpense.isfixed {
                    expenseData.fixedExpenseList.append(fetchedExpense)
                } else {
                    expenseData.variableExpenseList.append(fetchedExpense)
                }
            }
            
            // Calculate total expense
            
            let FixedExpensesSum = expenseData.fixedExpenseList.reduce(0.0) { (sum, expense) in
                 return sum + expense.amount
            }
             
            let VariableExpensesSum = expenseData.variableExpenseList.reduce(0.0) { (sum, expense) in
                 return sum + expense.amount
            }
             
            let totalExpenses = FixedExpensesSum + VariableExpensesSum
            expenseData.totalExpenses = totalExpenses
        
        } catch {
            // Something went wrong
            print("Something went wrong!")
        }
        
    }
}

#Preview {
    ExpensesTabView(expenseData: ExpenseData())
}
