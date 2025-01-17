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
    @State private var showToast = false
    var onSuccess: (() -> Void)? = nil
    
    @State private var includeIncomes = true
    @State private var includeFixedExpenses = true
    @State var isLandingPage: Bool = false
    
    @Environment(\.presentationMode) var presentationMode
    
    @State var budgetfb = BudgetFB()
    
    // Add state variables for dates
    @State private var startDate = Date()
    @State private var endDate = Calendar.current.date(byAdding: .month, value: 1, to: Date())!
    
    @State private var showValidationError = false
    @State private var validationMessage = ""
    
    private func validatePeriod() -> Bool {
        let calendar = Calendar.current
        let now = Date()
        
        // Check if start date is in the past
        if startDate < calendar.startOfDay(for: now) {
            validationMessage = "Start date cannot be in the past"
            showValidationError = true
            return false
        }
        
        // Check if end date is before start date
        if endDate < startDate {
            validationMessage = "End date must be after start date"
            showValidationError = true
            return false
        }
        
        // Check if period is too short (e.g., at least 1 day)
        let components = calendar.dateComponents([.day], from: startDate, to: endDate)
        if let days = components.day, days < 1 {
            validationMessage = "Budget period must be at least 1 day"
            showValidationError = true
            return false
        }
        
        return true
    }
        
    
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
                if validatePeriod() {
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
                                withAnimation {
                                    showToast = true
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    withAnimation {
                                        showToast = false
                                        onSuccess?()
                                        isPresented = false
                                    }
                                }
                            }
                        }
                    }
                }
            }) {
                ButtonView(buttontext: "Start New Period", maxWidth: 180)
            }
        }
        .alert("Invalid Budget Period", isPresented: $showValidationError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(validationMessage)
        }
        .overlay(alignment: .center) {
            if showToast {
                ToastView(message: "New period created successfully!")
                    .transition(.move(edge: .bottom))
                    .animation(.spring(), value: showToast)
            }
        }
        .scrollContentBackground(.hidden)
        .frame(maxWidth: .infinity)
        .frame(height: 500)
        .background(Color("TabColor"))
    }
}
struct ToastView: View {
    let message: String
    
    var body: some View {
        Text(message)
            .padding()
            .background(Color("CustomGreen"))
            .foregroundColor(.white)
            .cornerRadius(8)
            .padding(.bottom, 20)
            .shadow(radius: 5)
    }
}
struct NewBudgetPeriodView_Previews: PreviewProvider {
    static var previews: some View {
        NewBudgetPeriodView(isPresented: .constant(true), onSuccess: nil)
            .environmentObject(BudgetManager())
    }
}
