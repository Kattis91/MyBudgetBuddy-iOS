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
    
    var body: some View {
        
        ZStack {
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
                                showEditForm = true
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
                                showEditForm = true
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
