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
    
    @State var errorMessage = ""
    
    var body: some View {
        
        ZStack {
            if !showEditForm {
                List {
                    SectionView(
                        title: "Income",
                        categories: incomeCats,
                        onEdit: { category in
                            editingCategory = EditingCategory(name: category, type: .income)
                            showEditForm = true
                            closeNewCategoryField()
                        },
                        onDelete: { category in
                            selectedCategory = (category, .income)
                            showingDeleteAlert = true
                            closeNewCategoryField()
                        },
                        onAdd: {
                            withAnimation(.spring()) {
                                showNewIncomeField.toggle()
                            }
                            showNewFixedExpenseField = false
                            showNewVariableExpenseField = false
                        }
                    )
                    
                    if showNewIncomeField {
                        HStack {
                            CustomTextFieldView(placeholder: "Add new category", text: $incomeCat, isSecure: false, onChange: { errorMessage = ""
                            }, leadingPadding: 3, trailingPadding: 10, systemName: "square.grid.2x2")
                            Button(action: {
                                errorMessage = ""
                                incomeCat = ""
                                showNewIncomeField = false
                            }) {
                                Image(systemName: "arrow.uturn.backward")
                                    .foregroundColor(.blue)
                                    .padding(.trailing, 10)
                                    .padding(.bottom, 8)
                            }
                        }
                        
                        VStack {
                            if !errorMessage.isEmpty {
                                ErrorMessageView(errorMessage: errorMessage, height: 20)
                            }
                        }
                        .frame(height: 15)
                        
                        Button(action: {
                            if !incomeCat.isEmpty {
                                Task {
                                    _ = await budgetfb.addCategory(name: incomeCat, type: .income)
                                    await loadAllCategories()
                                    showNewIncomeField = false
                                }
                            } else {
                                errorMessage = "Please enter a category"
                            }
                        }) {
                            ButtonView(buttontext: "Save", maxWidth: 160, leadingPadding: 50, topPadding: 0)
                        }
                    }
                    
                    SectionView(
                        title: "Fixed Expense",
                        categories: fixedExpenseCats,
                        onEdit: { category in
                            editingCategory = EditingCategory(name: category, type: .fixedExpense)
                            showEditForm = true
                            closeNewCategoryField()
                        },
                        onDelete: { category in
                            selectedCategory = (category, .fixedExpense)
                            showingDeleteAlert = true
                            closeNewCategoryField()
                        },
                        onAdd: {
                            withAnimation(.spring()) {
                                showNewFixedExpenseField.toggle()
                            }
                            showNewIncomeField = false
                            showNewVariableExpenseField = false
                        }
                    )
                    if showNewFixedExpenseField {
                        HStack {
                            CustomTextFieldView(placeholder: "Add new category", text: $fixedExpenseCat, isSecure: false, onChange: { errorMessage = ""}, leadingPadding: 3, trailingPadding: 10, systemName: "square.grid.2x2")
                            Button(action: {
                                errorMessage = ""
                                fixedExpenseCat = ""
                                showNewFixedExpenseField = false
                            }) {
                                Image(systemName: "arrow.uturn.backward")
                                    .foregroundColor(.blue)
                                    .padding(.trailing, 10)
                                    .padding(.bottom, 8)
                            }
                        }
                        
                        VStack {
                            if !errorMessage.isEmpty {
                                ErrorMessageView(errorMessage: errorMessage, height: 20)
                            }
                        }
                        .frame(height: 15)
                        
                        Button(action: {
                            if !fixedExpenseCat.isEmpty {
                                Task {
                                    _ = await budgetfb.addCategory(name: fixedExpenseCat, type: .fixedExpense)
                                    await loadAllCategories()
                                    showNewFixedExpenseField = false
                                }
                            } else {
                                errorMessage = "Please enter a category"
                            }
                        }) {
                            ButtonView(buttontext: "Save", maxWidth: 160, leadingPadding: 50, topPadding: 0)
                        }
                    }
                    
                    SectionView(
                        title: "Variable Expense",
                        categories: variableExpenseCats,
                        onEdit:  { category in
                            editingCategory = EditingCategory(name: category, type: .variableExpense)
                            showEditForm = true
                            closeNewCategoryField()
                        },
                        onDelete: { category in
                            selectedCategory = (category, .variableExpense)
                            showingDeleteAlert = true
                            closeNewCategoryField()
                        },
                        onAdd: {
                            withAnimation(.spring()) {
                                showNewVariableExpenseField.toggle()
                            }
                            showNewIncomeField = false
                            showNewFixedExpenseField = false
                        }
                    )
                    if showNewVariableExpenseField {
                        HStack {
                            CustomTextFieldView(placeholder: "Add new category", text: $variableExpenseCat, isSecure: false, onChange: { errorMessage = ""}, leadingPadding: 3, trailingPadding: 10, systemName: "square.grid.2x2")
                            Button(action: {
                                errorMessage = ""
                                variableExpenseCat = ""
                                showNewVariableExpenseField = false
                            }) {
                                Image(systemName: "arrow.uturn.backward")
                                    .foregroundColor(.blue)
                                    .padding(.trailing, 10)
                                    .padding(.bottom, 8)
                            }
                        }
                        
                        VStack {
                            if !errorMessage.isEmpty {
                                ErrorMessageView(errorMessage: errorMessage, height: 20)
                            }
                        }
                        .frame(height: 15)
                        
                        Button(action: {
                            if !variableExpenseCat.isEmpty {
                                Task {
                                    _ = await budgetfb.addCategory(name: variableExpenseCat, type: .variableExpense)
                                    await loadAllCategories()
                                    showNewVariableExpenseField = false
                                }
                            } else {
                                errorMessage = "Please enter a category"
                            }
                        }) {
                            ButtonView(buttontext: "Save", maxWidth: 160, leadingPadding: 50, topPadding: 0)
                        }
                    }
                    
                }
                .scrollContentBackground(.hidden)
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
    
    func closeNewCategoryField() {
        showNewIncomeField = false
        showNewFixedExpenseField = false
        showNewVariableExpenseField = false
        incomeCat = ""
        fixedExpenseCat = ""
        variableExpenseCat = ""
        errorMessage = ""
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
