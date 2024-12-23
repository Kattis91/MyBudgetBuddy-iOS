//
//  IncomesTabView.swift
//  MyBudget
//
//  Created by Katya Durneva Svedmark on 2024-12-05.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct IncomesTabView: View {
    
    @State var budgetfb: BudgetFB
    
    //@ObservedObject var incomeData: IncomeData
    
    @State private var categories: [String] =
    ["Salary", "Study grant", "Child benefit", "Housing insurance", "Sickness insurance", "Business", "Something else?"]
    @State private var selectedCategory: String = "Salary"
    @State private var newCategory: String = ""
    
    @State private var incomeAmount: String = ""
    @State var errorMessage = ""
    
    @State var showSettings = false
    
    var body: some View {
        
        NavigationStack {
            VStack {
                
                Text("Total Income: \(budgetfb.totalIncome, specifier: "%.2f")")
                    .font(.largeTitle)
                    .bold()
                    .padding()
                
                HStack {
                    
                    CustomTextFieldView(placeholder: "Enter Income", text: $incomeAmount, isSecure: false, onChange: {
                        errorMessage = ""
                    }, trailingPadding: 5, systemName: "plus.circle")
                    
                    Picker("Select a Category", selection: $selectedCategory) {
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
                            .padding(.top, 13)
                        
                        Button(action: {
                            if !newCategory.isEmpty {
                                categories.append(newCategory)
                                selectedCategory = newCategory
                                newCategory = ""
                            }
                        }) {
                            ButtonView(buttontext: "Add", maxWidth: 80, greenBackground: true, leadingPadding: 10)
                        }
                    }
                }
                
                Button(action: {
                    if let income = Double(incomeAmount) { // Convert incomeAmount (String) to Double
                        if income > 0.00 {
                            incomeAmount = ""
                            budgetfb.saveIncomeData(amount: income, category: selectedCategory)
                            Task {
                                await budgetfb.loadIncomeData()
                            }
                        } else {
                            errorMessage = "Amount must be greater than zero."
                        }
                    } else {
                        errorMessage = "Amount must be a number."
                    }
                }) {
                    ButtonView(buttontext: "Add income", greenBackground: true)
                }
                
                ErrorMessageView(errorMessage: errorMessage, height: 20)
                
                CustomListView(
                    items: budgetfb.incomeList,
                    deleteAction: deleteIncomeItem,
                    itemContent: { income in
                        (category: income.category, amount: income.amount)
                    }, showNegativeAmount: false
                )
            }
            .task {
                await budgetfb.loadIncomeData()
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
    }
    // Bridge function
    private func deleteIncomeItem(at offsets: IndexSet) {
        budgetfb.deleteIncome(at: offsets)
    }
}

#Preview {
    IncomesTabView(budgetfb: BudgetFB())
}
