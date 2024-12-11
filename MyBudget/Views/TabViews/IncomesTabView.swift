//
//  IncomesTabView.swift
//  MyBudget
//
//  Created by Katya Durneva Svedmark on 2024-12-05.
//

import SwiftUI

struct IncomesTabView: View {
    
    @ObservedObject var incomeData: IncomeData
    
    @State private var categories: [String] =
    ["Salary", "Study grunt", "Child benefit", "Housing insurance", "Sickness insurance", "Business", "Something else?"]
    @State private var selectedCategory: String = "Salary"
    @State private var newCategory: String = ""
    
    @State private var incomeAmount: String = ""
    @State var errorMessage = ""
    
    var body: some View {
        
        VStack {
            
            Text("Total Income: \(incomeData.totalIncome, specifier: "%.2f")")
                .font(.largeTitle)
                .bold()
                .padding()
            
            HStack {
               
                CustomTextFieldView(placeholder: "Enter Income", text: $incomeAmount, isSecure: false, onChange: {
                    errorMessage = ""
                })
                
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
                    CustomTextFieldView(placeholder: "New category", text: $newCategory, isSecure: false)
                        .padding(.top, 11)
                    
                    Button(action: {
                        if !newCategory.isEmpty {
                            categories.append(newCategory)
                            selectedCategory = newCategory
                            newCategory = ""
                        }
                    }) {
                        ButtonView(buttontext: "Add", greenBackground: true)
                    }
                }
            }
            
            Button(action: {
                if let income = Double(incomeAmount) {
                    if income > 0.00 {
                        incomeData.addIncome(amount: income, category: selectedCategory)
                        incomeAmount = ""
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
            
            List {
                ForEach(incomeData.incomeList) { income in
                    HStack {
                        Text(income.category)
                        Spacer()
                        Text("\(income.amount, specifier: "%.2f")")
                    }
                }
                .onDelete(perform: incomeData.deleteIncome)
            }
            .background(Color.background)
            .scrollContentBackground(.hidden)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.background)
    }
}

#Preview {
    IncomesTabView(incomeData: IncomeData())
}
