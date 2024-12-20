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
    
    @State var budgetfb = BudgetFB()
    
    @ObservedObject var incomeData: IncomeData
    
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
                
                Text("Total Income: \(incomeData.totalIncome, specifier: "%.2f")")
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
                                await budgetfb.loadIncomeData(incomeData: incomeData)
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
                
                List {
                    ForEach(incomeData.incomeList) { income in
                        HStack {
                            Text(income.category)
                            Spacer()
                            Text("\(income.amount, specifier: "%.2f")")
                        }
                        .padding()
                    }
                    .onDelete(perform: deleteIncome)
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
            .task {
                await budgetfb.loadIncomeData(incomeData: incomeData)
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
    
    func deleteIncome(at offsets: IndexSet) {
       let userid = Auth.auth().currentUser?.uid
       guard let userid else { return }
       
       var ref: DatabaseReference!
       ref = Database.database().reference()
       
       for offset in offsets {
           print("DELETE \(offset)")
           let incomeItem = incomeData.incomeList[offset]
           print(incomeItem.id)
           print(incomeItem.category)
           ref.child("incomes").child(userid).child(incomeItem.id).removeValue()
       }
       
       // Update local data
       incomeData.incomeList.remove(atOffsets: offsets)
       
       // Recalculate total income
       incomeData.totalIncome = incomeData.incomeList.reduce(0.0) { $0 + $1.amount }
   }

    
}

#Preview {
    IncomesTabView(incomeData: IncomeData())
}
