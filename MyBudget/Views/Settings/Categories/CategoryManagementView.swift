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
    
    @State var incomeCat = ""
    @State var fixedExpenseCat = ""
    @State var variableExpenseCat = ""
    
    @State var errorMessage = ""
    
    @State private var showNewCategoryField = false
    @State private var selectedCategoryType: CategoryType? = nil
    
    @State private var selectedTab = 0
    
    var onCategoriesUpdate: () async -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        
        NavigationStack {
            ZStack {
                if !showEditForm && !showNewCategoryField {
                    VStack {
                        // Add segmented control
                        Picker("Category", selection: $selectedTab) {
                            Text("Incomes").tag(0)
                            Text("Fixed").tag(1)
                            Text("Variable").tag(2)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.vertical, 10)
                        .padding(.horizontal, 10)
                        
                        // Display the appropriate section based on tab selection
                        switch selectedTab {
                        case 0:
                            SectionView(
                                categories: incomeCats,
                                onEdit: { category in
                                    editingCategory = EditingCategory(name: category, type: .income)
                                    withAnimation(.spring()) {
                                        showEditForm = true
                                    }
                                    closeNewCategoryField()
                                },
                                onDelete: { category in
                                    selectedCategory = (category, .income)
                                    showingDeleteAlert = true
                                    closeNewCategoryField()
                                },
                                onAdd: {
                                    withAnimation(.spring()) {
                                        showNewCategoryField = true
                                    }
                                    selectedCategoryType = .income
                                }
                            )
                        case 1:
                            SectionView(
                                categories: fixedExpenseCats,
                                onEdit: { category in
                                    editingCategory = EditingCategory(name: category, type: .fixedExpense)
                                    withAnimation(.spring()) {
                                        showEditForm = true
                                    }
                                    closeNewCategoryField()
                                },
                                onDelete: { category in
                                    selectedCategory = (category, .fixedExpense)
                                    showingDeleteAlert = true
                                    closeNewCategoryField()
                                },
                                onAdd: {
                                    withAnimation(.spring()) {
                                        showNewCategoryField = true
                                    }
                                    selectedCategoryType = .fixedExpense
                                }
                            )
                        case 2:
                            SectionView(
                                categories: variableExpenseCats,
                                onEdit:  { category in
                                    editingCategory = EditingCategory(name: category, type: .variableExpense)
                                    withAnimation(.spring()) {
                                        showEditForm = true
                                    }
                                    closeNewCategoryField()
                                },
                                onDelete: { category in
                                    selectedCategory = (category, .variableExpense)
                                    showingDeleteAlert = true
                                    closeNewCategoryField()
                                },
                                onAdd: {
                                    withAnimation(.spring()) {
                                        showNewCategoryField = true
                                    }
                                    selectedCategoryType = .variableExpense
                                }
                            )
                        default:
                            EmptyView()
                        }
                    }
                    .background(Color.clear)
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
                }
                
                if let categoryType = selectedCategoryType, showNewCategoryField {
                    NewCategoryView(
                        isPresented: $showNewCategoryField,
                        budgetfb: budgetfb,
                        categoryType: categoryType,
                        onComplete: { await loadAllCategories() }
                    )
                }
            }
            .navigationTitle("Manage Categories")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        Task {
                            dismiss()
                        }
                    }) {
                        Image(systemName: "xmark")
                            .foregroundStyle(Color("ButtonsBackground"))
                    }
                }
            }
            .onChange(of: incomeCats) {
                Task {
                    await onCategoriesUpdate()
                }
            }
            .onChange(of: fixedExpenseCats) {
                Task {
                    await onCategoriesUpdate()
                }
            }
            .onChange(of: variableExpenseCats) {
                Task {
                    await onCategoriesUpdate()
                }
            }
        }
    }
    
    func closeNewCategoryField() {
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
    CategoryManagementView(budgetfb: BudgetFB(),
       onCategoriesUpdate: {
           // Simulate category update in preview
           print("Categories would update here")
       })
}
