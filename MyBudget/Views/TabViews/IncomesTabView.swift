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
                if let income = Double(incomeAmount) { // Convert incomeAmount (String) to Double
                    if income > 0.00 {
                        incomeData.addIncome(amount: income, category: selectedCategory)
                        incomeAmount = ""
                        budgetfb.saveIncomeData(amount: income, category: selectedCategory) // Pass the validated Double to saveIncomeData
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
        .task {
            // await getIncomeData()
            await loadIncomeData()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.background)
    }
    
    func loadIncomeData() async {
        
        guard let userid = Auth.auth().currentUser?.uid else { return }
        
        var ref: DatabaseReference!
        
        ref = Database.database().reference()
        
        do {
            let incomedata = try await ref.child("incomes").child(userid).getData()
            print(incomedata.childrenCount)
            
            incomeData.incomeList = []
            
            for incomeitem in incomedata.children {
                let incomesnap = incomeitem as! DataSnapshot
                
                // Access the "income data" child
                guard let incomeDataDict = incomesnap.childSnapshot(forPath: "incomedata").value as? [String: Any]
                else {
                    print("Failed to get income data")
                    continue
                }
                
                print(incomeDataDict)
                
                let fetchedIncome = Income(
                    amount: incomeDataDict["amount"] as? Double ?? 0.0,  // Default to 0.0 if not found
                    category: incomeDataDict["category"] as? String ?? "Unknown"  // Default to "Unknown" if not found
                )
                incomeData.incomeList.append(fetchedIncome)
            }
            
            // Calculate total income
           let totalIncome = incomeData.incomeList.reduce(0.0) { (sum, income) in
               return sum + income.amount
           }

           print("Total Income: \(totalIncome)")
           incomeData.totalIncome = totalIncome
        
        } catch {
            // Something went wrong
            print("Something went wrong!")
        }
        
    }
    
    
}

#Preview {
    IncomesTabView(incomeData: IncomeData())
}
