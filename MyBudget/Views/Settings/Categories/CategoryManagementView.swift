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
    
    var body: some View {
        
        List {
            Section("Income Categories") {
                ForEach(incomeCats, id: \.self) { category in
                    HStack {
                        Text(category)
                        Spacer()
                        Button(action: {
                            editingCategory = EditingCategory(name: category, type: .income)
                        }) {
                            Image(systemName: "square.and.pencil")
                        }
                        .padding()
                        .buttonStyle(BorderlessButtonStyle())
                        Button(action: {
                            
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                        .buttonStyle(BorderlessButtonStyle())
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
                        }) {
                            Image(systemName: "square.and.pencil")
                        }
                        .padding()
                        .buttonStyle(BorderlessButtonStyle())
                        Button(action: {
                            
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                        .buttonStyle(BorderlessButtonStyle())
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
                        }) {
                            Image(systemName: "square.and.pencil")
                        }
                        .padding()
                        .buttonStyle(BorderlessButtonStyle())
                        Button(action: {
                            
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                }
            }
        }
        .task {
            await loadAllCategories()
        }
        .sheet(item: $editingCategory) { category in
            EditCategorySheet(
                originalName: category.name,
                type: category.type,
                onSave: { newName in
                    Task {
                        _ = await budgetfb.editCategory(oldName: category.name, newName: newName, type: category.type)
                        await loadAllCategories()
                    }
                }
            )
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
