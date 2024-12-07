//
//  IncomesTabView.swift
//  MyBudget
//
//  Created by Katya Durneva Svedmark on 2024-12-05.
//

import SwiftUI

struct IncomesTabView: View {
    
    @State private var categories: [String] =
    ["Salary", "Study grunt", "Child benefit", "Housing insurance", "Sickness insurance", "Business", "Something else?"]
    @State private var selectedCategory: String = "Salary"
    @State private var newCategory: String = ""
    
    @State private var incomeAmount: String = ""
    @State private var totalIncome: Double = 0.0
    
    @State private var incomeList: [Income] = []
    
    var body: some View {
        
        VStack {
            
            Text("Total Income: \(totalIncome, specifier: "%.2f")")
                .font(.largeTitle)
                .bold()
                .padding()
            
            HStack {
               
                CustomTextFieldView(placeholder: "Enter Income", text: $incomeAmount, isSecure: false)
                
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
                if let income = Double(incomeAmount)  {
                    let newIncome = Income(amount: income, category: selectedCategory)
                    incomeList.append(newIncome)
                    totalIncome += income
                    incomeAmount = ""
                }
                
            }) {
                ButtonView(buttontext: "Add income", greenBackground: true)
            }
            
            List {
                ForEach(incomeList) { income in
                    HStack {
                        Text(income.category)
                        Spacer()
                        Text("\(income.amount, specifier: "%.2f")")
                    }
                    
                }
            }
        }
    }
}

#Preview {
    IncomesTabView()
}
