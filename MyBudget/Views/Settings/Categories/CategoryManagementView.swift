//
//  CategoryManagementView.swift
//  MyBudget
//
//  Created by Katya Durneva Svedmark on 2025-01-10.
//

import SwiftUI

struct CategoryManagementView: View {
    
    @State var budgetfb: BudgetFB
    @State private var incomeCats: [String] = []
    @State private var fixedExpenseCats: [String] = []
    @State private var variableExpenseCats: [String] = []
    
    var body: some View {
        
        List {
            Section("Income Categories") {
                ForEach(incomeCats, id: \.self) { category in
                    HStack {
                        Text(category)
                        Spacer()
                        Button(action: {
                            
                        }) {
                            Image(systemName: "square.and.pencil")
                        }
                        .padding()
                        Button(action: {
                            
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            Section("Fixed Expense Categories") {
                ForEach(fixedExpenseCats, id: \.self) { category in
                    HStack {
                        Text(category)
                        Spacer()
                        Button(action: {
                            
                        }) {
                            Image(systemName: "square.and.pencil")
                        }
                        .padding()
                        Button(action: {
                            
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            Section("Variable Expense Categories") {
                ForEach(variableExpenseCats, id: \.self) { category in
                    HStack {
                        Text(category)
                        Spacer()
                        Button(action: {
                            
                        }) {
                            Image(systemName: "square.and.pencil")
                        }
                        .padding()
                        Button(action: {
                            
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .task {
                await loadAllCategories()
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
