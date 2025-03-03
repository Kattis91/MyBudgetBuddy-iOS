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
   
    @State private var selectedView: ExpenseViewType = .fixed
    
    @State var budgetfb = BudgetFB()
    @EnvironmentObject var budgetManager: BudgetManager
    
    @State var showSettings = false
    @State private var refreshTrigger = UUID()
    
    @Binding var fixedErrorMessage: String
    @Binding var variableErrorMessage: String
    
    @State private var selectedTab = 0
    
    @Environment(\.colorScheme) var colorScheme
    var isDarkMode: Bool {
        return colorScheme == .dark
    }

    var body: some View {
        
        NavigationStack {
            VStack {
                VStack {
                    Text("Current Period:")
                        .font(.headline)
                        .padding(.bottom, 3)
                        .foregroundStyle(Color("PrimaryTextColor"))
                    Text(DateUtils.formattedDateRange(
                       startDate: budgetManager.currentPeriod.startDate,
                       endDate: budgetManager.currentPeriod.endDate)
                    )
                    .foregroundStyle(Color("PrimaryTextColor"))
                    .padding(.bottom, 5)
                    Text("Total expenses:")
                        .font(.headline)
                        .padding(.bottom, 3)
                        .foregroundStyle(Color("PrimaryTextColor"))
                    Text("\(budgetfb.totalExpenses,  specifier: "%.2f")")
                        .foregroundStyle(Color(red: 174/255, green: 41/255, blue: 114/255))
                        .fontWeight(.bold)
                }
                .padding(.horizontal)
                .padding(.vertical, 5)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: isDarkMode ?
                            [.darkGradientStart, .darkGradientEnd] :
                            [.backgroundTintLight, .backgroundTintDark]
                        ),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(16)
                .shadow(
                    color: isDarkMode ?
                        Color.black.opacity(0.25) :
                        Color.black.opacity(0.3),
                    radius: isDarkMode ? 3 : 1,
                    x: isDarkMode ? 0 : -2,
                    y: 3
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            isDarkMode ?
                                Color.white.opacity(0.08) :
                                Color.white.opacity(0.3),
                            lineWidth: 0.5
                        )
                )
                
                Picker("Expense types", selection: $selectedTab) {
                    Text("Fixed Expenses").tag(0)
                    Text("Variable Expenses").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal, isDarkMode ? 16 : 20)
                .padding(.top, 20)
                .padding(.bottom, 10)
                .onChange(of: selectedTab) {
                    // Clear both error messages when switching
                    fixedErrorMessage = ""
                    variableErrorMessage = ""
                }
                
                switch selectedTab {
                case 0:
                    ExpensesView(
                        viewtype: .fixed,
                        selectedCategory: "",
                        errorMessage: $fixedErrorMessage,
                        totalExpenses: $budgetfb.totalExpenses,
                        expenseList: $budgetfb.fixedExpenseList,
                        budgetfb: budgetfb
                    )
                    .id(refreshTrigger)
                case 1:
                    ExpensesView(
                        viewtype: .variable,
                        selectedCategory: "",
                        errorMessage: $variableErrorMessage,
                        totalExpenses: $budgetfb.totalExpenses,
                        expenseList: $budgetfb.variableExpenseList,
                        budgetfb: budgetfb
                    )
                    .id(refreshTrigger)
                default:
                    EmptyView()
                }
            }
            .task {
                await budgetfb.loadExpenseData(isfixed: true)
                await budgetfb.loadExpenseData(isfixed: false)// Ensure data is loaded when the view appears
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    CustomSettingsMenu(
                        budgetfb: budgetfb,
                        onCategoriesUpdate: {
                            // Load both fixed and variable expenses after category updates
                            await budgetfb.loadExpenseData(isfixed: true)
                            await budgetfb.loadExpenseData(isfixed: false)
                            _ = await budgetfb.loadCategories(type: .fixedExpense)
                            _ = await budgetfb.loadCategories(type: .variableExpense)
                            await MainActor.run {
                                refreshTrigger = UUID() // Force view refresh
                            }
                        }
                    )
                }
            }
        }
    }
}

#Preview {
    ExpensesTabView(
        budgetfb: BudgetFB(),
        fixedErrorMessage: .constant(""),
        variableErrorMessage: .constant("")
    )
    .environmentObject(BudgetManager())
}
