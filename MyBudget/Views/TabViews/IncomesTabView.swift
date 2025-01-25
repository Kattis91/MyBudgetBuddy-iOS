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
    @State var errorMessage = ""
    
    @State var showSettings = false
    
    @State var showNewCategoryField = false
    
    var body: some View {
        
        NavigationStack {
            VStack {
                VStack {
                    Text("Current Period:")
                        .font(.headline)
                        .padding(.bottom, 10)
                    Text(DateUtils.formattedDateRange(
                       startDate: budgetManager.currentPeriod.startDate,
                       endDate: budgetManager.currentPeriod.endDate
                   ))
                }
                .padding()
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [.backgroundTintLight, .backgroundTintDark]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(16)
                .shadow(
                    color: .black.opacity(0.3),
                    radius: 4,
                    x: 0,
                    y: 2
                )
                // Add subtle border for more definition
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.3), lineWidth: 0.5)
                )
                
                Text("Total Income: \(budgetfb.totalIncome, specifier: "%.2f")")
                    .font(.title)
                    .bold()
                    .padding()
                
                VStack {
                    
                    CustomTextFieldView(placeholder: "Enter Income", text: $incomeAmount, isSecure: false, onChange: {
                        errorMessage = ""
                    }, leadingPadding: 33, trailingPadding: 33, systemName: "plus.circle")
                    
                    if showNewCategoryField {
                        HStack {
                            CustomTextFieldView(placeholder: "New category", text: $newCategory, isSecure: false, leadingPadding: 33, systemName: "square.grid.2x2")
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
                        .padding(.top, 10)
                        
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
                                Text(selectedCategory.isEmpty ? "Category" : selectedCategory)
                                    .foregroundColor(selectedCategory.isEmpty ? .gray : .primary)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 245/255, green: 247/255, blue: 245/255), // Light gray
                                        Color(red: 240/255, green: 242/255, blue: 240/255)  // Slightly darker gray
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                            .shadow(
                                color: .black.opacity(0.25),
                                radius: 1,
                                x: 0,
                                y: 4
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.4), lineWidth: 0.8)
                            )
                        }
                        .padding(.bottom)
                        .padding(.horizontal, 33)
                    }
                }
                
                ErrorMessageView(errorMessage: errorMessage, height: 15)
                
                Button(action: {
                    if let income = Double(incomeAmount) { // Convert incomeAmount (String) to Double
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
                                                errorMessage = "Failed to add category"
                                            }
                                        }
                                    }
                                } else {
                                    errorMessage = "Please add a category"
                                }
                            } else {
                                if !selectedCategory.isEmpty {
                                    let categoryToUse = selectedCategory
                                    incomeAmount = ""
                                    budgetfb.saveIncomeData(amount: income, category: categoryToUse)
                                    selectedCategory = ""
                                } else {
                                    errorMessage = "Please select a category."
                                }
                            }
                        } else {
                            errorMessage = "Amount must be greater than zero."
                        }
                    } else {
                        errorMessage = "Amount must be a number."
                    }
                }) {
                    ButtonView(buttontext: "Add income", incomeButton: true, leadingPadding: 33, trailingPadding: 33)
                }
                
                CustomListView(
                    items: budgetfb.incomeList,
                    deleteAction: deleteIncomeItem,
                    itemContent: { income in
                        (category: income.category, amount: income.amount)
                    }, showNegativeAmount: false
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
        .sheet(isPresented: $showSettings) {
            Task {
                let loadedCategories = await budgetfb.loadCategories(type: .income)
                categories = loadedCategories
            }
        } content: {
            SettingsView(budgetfb: budgetfb)
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
        IncomesTabView(budgetfb: BudgetFB())
            .environmentObject(BudgetManager()) // Lägg till BudgetManager här
    }
}
