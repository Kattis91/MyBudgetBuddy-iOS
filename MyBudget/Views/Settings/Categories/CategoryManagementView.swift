//
//  CategoryManagementView.swift
//  MyBudget
//
//  Created by Katya Durneva Svedmark on 2025-01-10.
//

import SwiftUI

struct EditingCategory: Identifiable {
    let id = UUID()
    let name: String
    let type: CategoryType
}

struct CategoryManagementView: View {
    
    @State var budgetfb: BudgetFB
    @State private var incomeCats: [String] = []
    @State private var fixedExpenseCats: [String] = []
    @State private var variableExpenseCats: [String] = []
    
    @State private var editingCategory: EditingCategory? = nil
    
    @State var showEditForm = false
    @State var showingDeleteAlert = false
    @State private var selectedCategory: (String, CategoryType)?
    
    @State var showNewIncomeField = false
    @State var showNewFixedExpenseField = false
    @State var showNewVariableExpenseField = false
    
    @State var incomeCat = ""
    @State var fixedExpenseCat = ""
    @State var variableExpenseCat = ""
    
    var body: some View {
        
        ZStack {
            if !showEditForm {
                List {
                    Section("Income Categories") {
                        ForEach(incomeCats, id: \.self) { category in
                            HStack {
                                Text(category)
                                Spacer()
                                Button(action: {
                                    editingCategory = EditingCategory(name: category, type: .income)
                                    showEditForm = true
                                }) {
                                    Image(systemName: "square.and.pencil")
                                }
                                .padding()
                                .buttonStyle(BorderlessButtonStyle())
                                Button(action: {
                                    Task {
                                        selectedCategory = (category, .income)
                                        showingDeleteAlert = true
                                    }
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                            }
                        }
                        Button (action: {
                            showNewIncomeField = true
                        }) {
                            Text("+ Add Income Category")
                        }
                        if showNewIncomeField {
                            HStack {
                                CustomTextFieldView(placeholder: "Add new category", text: $incomeCat, isSecure: false, leadingPadding: 3, trailingPadding: 10, systemName: "square.grid.2x2")
                                Button(action: {
                                    showNewIncomeField = false
                                }) {
                                    Image(systemName: "arrow.uturn.backward")
                                        .foregroundColor(.blue)
                                        .padding(.trailing, 10)
                                        .padding(.bottom, 8)
                                }
                            }
                            Button(action: {
                                Task {
                                    _ = await budgetfb.addCategory(name: incomeCat, type: .income)
                                    await loadAllCategories()
                                }
                            }) {
                                ButtonView(buttontext: "Save", maxWidth: 160, leadingPadding: 50, topPadding: 0)
                            }
                        }
                    }
                    Section("Fixed Expense Categories") {
                        ForEach(fixedExpenseCats, id: \.self) { category in
                            HStack {
                                Text(category)
                                Spacer()
                                Button(action: {
                                    editingCategory = EditingCategory(name: category, type: .fixedExpense)
                                    showEditForm = true
                                }) {
                                    Image(systemName: "square.and.pencil")
                                }
                                .padding()
                                .buttonStyle(BorderlessButtonStyle())
                                Button(action: {
                                    selectedCategory = (category, .fixedExpense)
                                    showingDeleteAlert = true
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                            }
                        }
                        Button (action: {
                            showNewFixedExpenseField = true
                        }) {
                            Text("+ Add Fixed Expense Category")
                        }
                        if showNewFixedExpenseField {
                            HStack {
                                CustomTextFieldView(placeholder: "Add new category", text: $fixedExpenseCat, isSecure: false, leadingPadding: 3, trailingPadding: 10, systemName: "square.grid.2x2")
                                Button(action: {
                                    showNewFixedExpenseField = false
                                }) {
                                    Image(systemName: "arrow.uturn.backward")
                                        .foregroundColor(.blue)
                                        .padding(.trailing, 10)
                                        .padding(.bottom, 8)
                                }
                            }
                            Button(action: {
                                Task {
                                    _ = await budgetfb.addCategory(name: fixedExpenseCat, type: .fixedExpense)
                                    await loadAllCategories()
                                }
                            }) {
                                ButtonView(buttontext: "Save", maxWidth: 160, leadingPadding: 50, topPadding: 0)
                            }
                        }
                    }
                    Section("Variable Expense Categories") {
                        ForEach(variableExpenseCats, id: \.self) { category in
                            HStack {
                                Text(category)
                                Spacer()
                                Button(action: {
                                    editingCategory = EditingCategory(name: category, type: .variableExpense)
                                    showEditForm = true
                                }) {
                                    Image(systemName: "square.and.pencil")
                                }
                                .padding()
                                .buttonStyle(BorderlessButtonStyle())
                                Button(action: {
                                    selectedCategory = (category, .variableExpense)
                                    showingDeleteAlert = true
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                            }
                        }
                        Button (action: {
                            showNewVariableExpenseField = true
                        }) {
                            Text("+ Add Variable Expense Category")
                        }
                        if showNewVariableExpenseField {
                            HStack {
                                CustomTextFieldView(placeholder: "Add new category", text: $variableExpenseCat, isSecure: false, leadingPadding: 3, trailingPadding: 10, systemName: "square.grid.2x2")
                                Button(action: {
                                    showNewVariableExpenseField = false
                                }) {
                                    Image(systemName: "arrow.uturn.backward")
                                        .foregroundColor(.blue)
                                        .padding(.trailing, 10)
                                        .padding(.bottom, 8)
                                }
                            }
                            Button(action: {
                                Task {
                                    _ = await budgetfb.addCategory(name: variableExpenseCat, type: .variableExpense)
                                    await loadAllCategories()
                                }
                            }) {
                                ButtonView(buttontext: "Save", maxWidth: 160, leadingPadding: 50, topPadding: 0)
                            }
                        }
                    }
                }
                .alert("Are you sure you want to delete \(selectedCategory?.0 ?? "this category")?", isPresented: $showingDeleteAlert) {
                    Button("Cancel", role: .cancel) { }
                    Button("Delete", role: .destructive) {
                        if let (category, type) = selectedCategory {
                            Task {
                                _ = await budgetfb.deleteCategory(name: category, type: type)
                                await loadAllCategories()
                            }
                        }
                    }
                }
                .task {
                    await loadAllCategories()
                }
            }
            if showEditForm {
                EditCategoryView(
                    isPresented: $showEditForm,
                    budgetfb: budgetfb,
                    category: editingCategory!,
                    onComplete: { await loadAllCategories() }
                )
                .frame(height: 270)
                .background(Color.white)
                .padding(.horizontal, 24)
                .cornerRadius(12)
                .shadow(radius: 10)
            }
        }
    }
    
    private func loadAllCategories() async {
        incomeCats = await budgetfb.loadCategories(type: .income)
        fixedExpenseCats = await budgetfb.loadCategories(type: .fixedExpense)
        variableExpenseCats = await budgetfb.loadCategories(type: .variableExpense)
    }
}

#Preview {
    CategoryManagementView(budgetfb: BudgetFB())
}
