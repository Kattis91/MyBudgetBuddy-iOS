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
    @EnvironmentObject var budgetManager: BudgetManager
   
    @State private var categories: [String] = []
    @State private var selectedCategory: String = ""
    @State private var newCategory: String = ""
    
    @State private var isPickerOpen: Bool = false
    @State private var isIncomeAdded: Bool = false
    
    @State private var incomeAmount: String = ""
    @Binding var errorMessage: String 
    
    @State var showSettings = false
    
    @State var showNewCategoryField = false
    
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
                       endDate: budgetManager.currentPeriod.endDate
                   ))
                    .foregroundStyle(Color("PrimaryTextColor"))
                    .padding(.bottom, 5)
                    Text("Total Income:")
                        .font(.headline)
                        .padding(.bottom, 3)
                        .foregroundStyle(Color("PrimaryTextColor"))
                    Text("\(budgetfb.totalIncome, specifier: "%.2f")")
                        .foregroundStyle(Color(red: 78/255, green: 177/255, blue: 181/255))
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
                
                VStack {
                    
                    CustomTextFieldView(placeholder: String(localized: "Enter Income"), text: $incomeAmount, isSecure: false, onChange: {
                        errorMessage = ""
                    }, leadingPadding: isDarkMode ? 15 : 20, trailingPadding: isDarkMode ? 15 : 20, systemName: "plus.circle", maxLength: 15)
                    .padding(.top, 20)
                    
                    if showNewCategoryField {
                        HStack {
                            CustomTextFieldView(placeholder: "New category", text: $newCategory, isSecure: false, leadingPadding: 33, systemName: "tag", maxLength: 30)
                            Button(action: {
                                showNewCategoryField = false
                                selectedCategory = ""
                                newCategory = ""
                            }) {
                                Image(systemName: "arrow.uturn.backward")
                                    .foregroundColor(.blue)
                                    .padding(.trailing, 33)
                                    .padding(.bottom, 8)
                            }
                        }
                        .padding(.top, 5)
                        
                    } else {
                        Menu {
                            ForEach(categories, id: \.self) { category in
                                Button(category) {
                                    selectedCategory = category
                                }
                            }
                            Button("+ Add new category") {
                                selectedCategory = "new"
                                showNewCategoryField = true
                            }
                        } label: {
                            HStack {
                                Text(selectedCategory.isEmpty ? String(localized: "Choose Category") : selectedCategory)
                                    .foregroundColor(isDarkMode ? .white.opacity(0.8) : .black.opacity(0.5))
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 10)
                            .padding(.horizontal)
                            //.background(Color(red: 92/255, green: 92/255, blue: 94/255))
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: isDarkMode ?
                                        [.inputGradientLight, .inputGradientDark] :
                                        [Color(red: 245/255, green: 247/255, blue: 245/255),
                                         Color(red: 240/255, green: 242/255, blue: 240/255)]),
                                    startPoint: isDarkMode ? .topLeading : .leading,
                                    endPoint: isDarkMode ? .bottomTrailing : .trailing
                                )
                            )
                            .cornerRadius(18)
                            .shadow(
                                color: .black.opacity(0.25),
                                radius: 1,
                                x: -2,
                                y: 4
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.4), lineWidth: 0.8)
                            )
                        }
                        .padding(.bottom, 3)
                        .padding(.horizontal, isDarkMode ? 15 : 20)
                    }
                }
                
                ErrorMessageView(errorMessage: errorMessage, height: 15)
                
                Button(action: {
                    // Replace comma with period to handle European decimal format
                    let normalizedAmount = incomeAmount.replacingOccurrences(of: ",", with: ".")
    
                    if let income = Double(normalizedAmount) { // Convert incomeAmount (String) to Double
                        if income > 0.00 {
                            if showNewCategoryField {
                                if !newCategory.isEmpty {
                                    Task {
                                        let success = await budgetfb.addCategory(name: newCategory, type: .income)
                                        if success {
                                            // Update UI on main thread
                                            await MainActor.run {
                                                categories.append(newCategory)
                                                let categoryToUse = newCategory
                                                incomeAmount = ""
                                                budgetfb.saveIncomeData(amount: income, category: categoryToUse)
                                                showNewCategoryField = false
                                                selectedCategory = ""
                                            }
                                        } else {
                                            await MainActor.run {
                                                errorMessage = String(localized: "Failed to add category")
                                            }
                                        }
                                    }
                                } else {
                                    errorMessage = String(localized: "Please add a category")
                                }
                            } else {
                                if !selectedCategory.isEmpty {
                                    let categoryToUse = selectedCategory
                                    incomeAmount = ""
                                    budgetfb.saveIncomeData(amount: income, category: categoryToUse)
                                    selectedCategory = ""
                                } else {
                                    errorMessage = String(localized: "Please select a category.")
                                }
                            }
                        } else {
                            errorMessage = String(localized: "Amount must be greater than zero.")
                        }
                    } else {
                        errorMessage = String(localized: "Amount must be a number.")
                    }
                }) {
                    ButtonView(buttontext: String(localized: "Add income"), incomeButton: true, height: 41, leadingPadding: isDarkMode ? 15 : 20, trailingPadding: isDarkMode ? 15 : 20, topPadding: 5)
                }
                .padding(.bottom, 15)
                
                if !budgetfb.incomeList.isEmpty {
                    HStack {
                        Image(systemName: "arrow.left.to.line")
                            .font(.caption)
                        Text("Swipe left to delete incomes")
                            .font(.caption)
                    }
                    .foregroundStyle(Color("PrimaryTextColor"))
                    .padding(.horizontal)
                }
                
                CustomListView(
                    items: budgetfb.incomeList,
                    deleteAction: deleteIncomeItem,
                    itemContent: { income in
                        (category: income.category, amount: income.amount, date: nil)
                    }, isCurrent: true,
                    showNegativeAmount: false,
                    alignAmountInMiddle: false,
                    isInvoice: false,
                    onMarkProcessed: nil
                )
            }
            .onAppear() {
                Task {
                    await budgetfb.loadCategories(type: .income)
                }
            }
            .task {
                await loadInitialData()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    CustomSettingsMenu(
                        budgetfb: budgetfb,
                        onCategoriesUpdate: {
                            let loadedCategories = await budgetfb.loadCategories(type: .income)
                            categories = loadedCategories
                        }
                    )
                }
            }
        }
    }
    
    private func loadInitialData() async {
        // Load income data
        await budgetfb.loadIncomeData()
        
        // Load categories and update the state
        let loadedCategories = await budgetfb.loadCategories(type: .income)
        categories = loadedCategories
    }
    
    // Bridge function
    private func deleteIncomeItem(at offsets: IndexSet) {
        budgetfb.deleteIncome(at: offsets)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

struct IncomesTabView_Previews: PreviewProvider {
    static var previews: some View {
        IncomesTabView(
            budgetfb: BudgetFB(),
            errorMessage: .constant("")  // Add this line
        )
        .environmentObject(BudgetManager())
    }
}
