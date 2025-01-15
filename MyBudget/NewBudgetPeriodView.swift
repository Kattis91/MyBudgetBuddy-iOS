//
//  NewBudgetPeriodView.swift
//  MyBudget
//
//  Created by Katya Durneva Svedmark on 2024-12-28.
//

import SwiftUI

struct NewBudgetPeriodView: View {
    
    @EnvironmentObject var budgetManager: BudgetManager
    @Binding var isPresented: Bool
    @State private var showConfirmation = false
    
    @State private var includeIncomes = true
    @State private var includeFixedExpenses = true
    @State var isLandingPage: Bool = false
    
    @Environment(\.presentationMode) var presentationMode
    
    @State var budgetfb = BudgetFB()
    
    // Add state variables for dates
    @State private var startDate = Date()
    @State private var endDate = Calendar.current.date(byAdding: .month, value: 1, to: Date())!
        
    
    var body: some View {
        
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    isPresented = false
                }) {
                    Image(systemName: "xmark")
                        .foregroundStyle(Color.red)
                        .padding(.horizontal)
                }
            }
            
            // Add DatePicker views
            VStack(alignment: .leading) {
                Text("Period Dates")
                    .fontDesign(.rounded)
                    .tracking(1.5)
                
                DatePicker("Start Date",
                    selection: $startDate,
                    displayedComponents: [.date]
                )
                .padding(.vertical, 5)
                
                DatePicker("End Date",
                    selection: $endDate,
                    in: startDate...,  // Ensures end date can't be before start date
                    displayedComponents: [.date]
                )
                .padding(.vertical, 5)
            }
            .padding(.horizontal, 45)
            
            if !isLandingPage {
                HStack {
                    Text("Transfer Settings")
                        .fontDesign(.rounded)
                        .tracking(1.5)
                    Spacer()
                }
                .padding(.horizontal, 45)
                Toggle("Include Incomes", isOn: $includeIncomes)
                    .tint(Color("CustomGreen"))
                    .padding(.horizontal, 45)
                
                if includeIncomes {
                    VStack(alignment: .leading) {
                        Text("Incomes to be transferred:")
                            .font(.subheadline)
                            .padding(.top)
                        ForEach(budgetManager.incomeList, id: \.id) { income in
                            Text(income.category + ": " + String(format: "%.2f", income.amount))
                                .font(.body)
                        }
                    }
                    .padding(.horizontal, 45)
                }
                Toggle("Include Fast Expenses", isOn: $includeFixedExpenses)
                    .tint(Color("CustomGreen"))
                    .padding(.horizontal, 45)
                    .padding(.bottom, 10)
                
                if includeFixedExpenses {
                    VStack(alignment: .leading) {
                        Text("Fixed Expenses to be transferred:")
                            .font(.subheadline)
                            .padding(.top)
                        ForEach(budgetManager.fixedExpenseList, id: \.id) { expense in
                            Text(expense.category + ": " + String(format: "%.2f", expense.amount))
                                .font(.body)
                        }
                    }
                    .padding(.horizontal, 45)
                }
            }
            
            
            Button(action: {
                // First create the new period
                let newPeriod = budgetManager.startNewPeriod(
                    startDate: startDate,
                    endDate: endDate,
                    includeIncomes: includeIncomes,
                    includeFixedExpenses: includeFixedExpenses
                )
                
                budgetfb.saveBudgetPeriod(newPeriod, transferData: (
                    incomes: includeIncomes,
                    expenses: includeFixedExpenses
                ),  isfixed: includeFixedExpenses) { success in
                    if success {
                        Task {
                            await budgetManager.updateCurrentPeriodData(newPeriod)
                            showConfirmation = true
                            isPresented = false
                        }
                    }
                }
            }) {
                ButtonView(buttontext: "Start New Period", maxWidth: 180)
            }
        }
        .alert(isPresented: $showConfirmation) {
            Alert(title: Text("Success"), message: Text("A new period has been created!"), dismissButton: .default(Text("OK")))
        }
        .scrollContentBackground(.hidden)
        .frame(maxWidth: .infinity)
        .frame(height: 500)
        .background(Color("TabColor"))
    }
}

struct NewBudgetPeriodView_Previews: PreviewProvider {
    static var previews: some View {
        NewBudgetPeriodView(isPresented: .constant(true))
            .environmentObject(BudgetManager())
    }
}
