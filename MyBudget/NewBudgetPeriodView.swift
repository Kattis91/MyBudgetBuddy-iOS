//
//  NewBudgetPeriodView.swift
//  MyBudget
//
//  Created by Katya Durneva Svedmark on 2024-12-28.
//

import SwiftUI

struct NewBudgetPeriodView: View {
    
    @Environment(\.colorScheme) var colorScheme
    var isDarkMode: Bool {
        return colorScheme == .dark
    }
    
    @EnvironmentObject var budgetManager: BudgetManager
    @Binding var isPresented: Bool
    @State private var showToast = false
    var onSuccess: (() -> Void)? = nil
    
    @State private var includeIncomes = true
    @State private var includeFixedExpenses = true
    @State var isLandingPage: Bool = false
    @State var noCurrentPeriod: Bool = false
    
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
                        .foregroundStyle(Color("ButtonsBackground"))
                        .padding(.horizontal)
                        .padding(.top, 20)
                }
            }
            
            // Add DatePicker views
            VStack(alignment: .leading) {
                Text("Period Dates")
                    .fontDesign(.rounded)
                    .tracking(1.5)
                    .font(.title3)
                    .foregroundStyle(Color("PrimaryTextColor"))
                
                DatePicker("Start Date",
                    selection: $startDate,
                    displayedComponents: [.date]
                )
                .foregroundStyle(Color("PrimaryTextColor"))
                
                DatePicker("End Date",
                    selection: $endDate,
                    in: startDate...,  // Ensures end date can't be before start date
                    displayedComponents: [.date]
                )
                .foregroundStyle(Color("PrimaryTextColor"))
            }
            .padding(.horizontal, 35)
            
            if !isLandingPage {
                if !budgetManager.incomeList.isEmpty || !budgetManager.fixedExpenseList.isEmpty {
                    HStack {
                        Text("Transfer Settings")
                            .fontDesign(.rounded)
                            .tracking(1.5)
                            .font(.title3)
                            .foregroundStyle(Color("PrimaryTextColor"))
                        Spacer()
                    }
                    .padding(.horizontal, 35)
                    .padding(.vertical, 10)
                }
                
                if !budgetManager.incomeList.isEmpty {
                    Toggle("Include Incomes", isOn: $includeIncomes)
                        .tint(
                            LinearGradient(
                            gradient: Gradient(colors: [
                              .addIncomeStart,   // Start color
                              .addIncomeMiddle,  // Middle color
                              .addIncomeEnd     // End color
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing)
                        )
                        .padding(.horizontal, 35)
                        .foregroundStyle(Color("PrimaryTextColor"))
                    
                    if includeIncomes {
                        VStack(alignment: .leading, spacing: 18) {
                            ScrollView {
                                VStack(alignment: .leading, spacing: 0) {
                                    ForEach(budgetManager.incomeList, id: \.id) { income in
                                        HStack {
                                            Text(income.category)
                                            Spacer()
                                            Text(String(format: "%.2f", income.amount))
                                        }
                                        .padding(.horizontal, 12) // Reduced horizontal padding
                                        .padding(.vertical, 8)    // Reduced vertical padding
                                        .background(
                                            LinearGradient(
                                                gradient: Gradient(colors: isDarkMode ?
                                                   [.inputGradientLight, .inputGradientDark] :
                                                   [.backgroundTintLight, .backgroundTintDark]
                                                ),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .cornerRadius(12)
                                        .shadow(
                                            color: isDarkMode ? Color.black.opacity(0.6) : Color.black.opacity(0.3),
                                            radius: isDarkMode ? 6 : 2,
                                            x: 0,
                                            y: isDarkMode ? 6 : 4
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(isDarkMode ? Color.white.opacity(0.5) : Color.white.opacity(0.3), lineWidth: 0.4)
                                                .shadow(color: isDarkMode ? Color.white.opacity(0.05) : Color.clear, radius: 5)
                                        )
                                        .padding(.horizontal, 4)
                                        .foregroundColor(Color("PrimaryTextColor"))
                                    }
                                    .padding(.bottom, 6)
                                }
                            }
                            .frame(height: min(CGFloat(budgetManager.incomeList.count * 44), 125))
                            
                            if budgetManager.incomeList.count > 3 {
                                HStack {
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(.gray)
                                        .opacity(0.6)
                                        .font(.caption)
                                    Spacer()
                                }
                                .offset(y: -12)
                            }
                        }
                        .padding(.horizontal, 35)
                    }
                }
                
                if !budgetManager.fixedExpenseList.isEmpty {
                    Toggle("Include Fast Expenses", isOn: $includeFixedExpenses)
                        .tint(
                            LinearGradient(
                            gradient: Gradient(colors: [
                              .addIncomeStart,   // Start color
                              .addIncomeMiddle,  // Middle color
                              .addIncomeEnd     // End color
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing)
                        )
                        .padding(.horizontal, 35)
                        .padding(.bottom, 10)
                        .foregroundStyle(Color("PrimaryTextColor"))
                    
                    if includeFixedExpenses {
                        VStack(alignment: .leading, spacing: 18) {
                            ScrollView {
                                VStack(alignment: .leading, spacing: 0) {
                                    ForEach(budgetManager.fixedExpenseList, id: \.id) { expense in
                                        HStack {
                                            Text(expense.category)
                                            Spacer()
                                            Text(String(format: "%.2f", expense.amount))
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(
                                            LinearGradient(
                                                gradient: Gradient(colors: isDarkMode ?
                                                   [.inputGradientLight, .inputGradientDark] :
                                                   [.backgroundTintLight, .backgroundTintDark]
                                                ),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .cornerRadius(12)
                                        .shadow(
                                            color: isDarkMode ? Color.black.opacity(0.6) : Color.black.opacity(0.3),
                                            radius: isDarkMode ? 6 : 2,
                                            x: 0,
                                            y: isDarkMode ? 6 : 4
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(isDarkMode ? Color.white.opacity(0.5) : Color.white.opacity(0.3), lineWidth: 0.4)
                                                .shadow(color: isDarkMode ? Color.white.opacity(0.05) : Color.clear, radius: 5)
                                        )
                                        .padding(.horizontal, 4)
                                        .foregroundColor(Color("PrimaryTextColor"))
                                    }
                                    .padding(.bottom, 6)
                                }
                            }
                            .frame(height: min(CGFloat(budgetManager.fixedExpenseList.count * 44), 125))
                            
                            if budgetManager.fixedExpenseList.count > 3 {
                                HStack {
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(.gray)
                                        .opacity(0.6)
                                        .font(.caption)
                                    Spacer()
                                }
                                .offset(y: -12)
                            }
                        }
                        .padding(.horizontal, 35)
                    }
                }
            }
            
            
            Button(action: {
                if validatePeriod() {
                    // We use createCleanBudgetPeriod for any user without a current period
                    // (both first-time users and users with expired periods) to prevent
                    // data inheritance issues between users or periods
                    if isLandingPage && noCurrentPeriod {
                        budgetfb.createCleanBudgetPeriod(startDate: startDate, endDate: endDate) { success in
                            if success {
                                Task {
                                    // Create a local budget period object to update UI
                                    let newPeriod = BudgetPeriod(
                                        startDate: startDate,
                                        endDate: endDate,
                                        incomes: [],
                                        fixedExpenses: [],
                                        variableExpenses: []
                                    )
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
                    } else {
                        // Standard flow with optional data transfer for users with active periods
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
                }
            }) {
                ButtonView(buttontext: String(localized: "Start New Period"), maxWidth: 180, incomeButton: true)
                    .padding(.bottom, 25)
            }
        }
        .alert("Invalid Budget Period", isPresented: $showValidationError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(validationMessage)
        }
        .overlay(alignment: .center) {
            if showToast {
                ToastView(message: String(localized: "New period created successfully!"))
                    .transition(.move(edge: .bottom))
                    .animation(.spring(), value: showToast)
            }
        }
        .scrollContentBackground(.hidden)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                gradient: Gradient(colors: colorScheme == .dark ? [
                    Color(.darkGray), Color(.black)
                ] : [
                    Color(red: 245/255, green: 247/255, blue: 245/255),
                    Color(red: 240/255, green: 242/255, blue: 240/255)
                ]),
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(16)
        .shadow(
            color: colorScheme == .dark ?
                .black.opacity(0.35) :
                .black.opacity(0.25),
            radius: colorScheme == .dark ? 2 : 1,
            x: -2,
            y: 4
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    colorScheme == .dark ?
                        Color.white.opacity(0.2) :
                        Color.white.opacity(0.4),
                    lineWidth: 0.8
                )
        )
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
