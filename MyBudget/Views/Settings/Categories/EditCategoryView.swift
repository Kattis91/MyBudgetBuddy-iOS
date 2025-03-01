//
//  EditCategoryView.swift
//  MyBudget
//
//  Created by Katya Durneva Svedmark on 2025-01-12.
//

import SwiftUI

struct EditCategoryView: View {
    
    @Environment(\.colorScheme) var colorScheme
    var isDarkMode: Bool {
        return colorScheme == .dark
    }
    
    @Binding var isPresented: Bool
    @State var budgetfb: BudgetFB
    let category: EditingCategory
    let onComplete: () async -> Void
    
    @State private var categoryName = ""
    @State private var errorMessage = ""
    
    private func getCategoryTypeString() -> String {
        switch category.type {
        case .income:
            return String(localized: "Income")
        case .fixedExpense:
            return String(localized: "Fixed Expense")
        case .variableExpense:
            return String(localized: "Variable Expense")
        }
    }
    
    var body: some View {
        
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    isPresented = false
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(Color("ButtonsBackground"))
                }
            }
            
            VStack(spacing: 4) {
                Text("Editing")
                    .font(.title3)
                    .foregroundStyle(Color("PrimaryTextColor"))
                
                Text("\(getCategoryTypeString()) category")
                    .font(.headline)
                    .foregroundStyle(Color("PrimaryTextColor"))
            }
            .padding(.vertical, 25)
            
            CustomTextFieldView(placeholder: String(localized: "Category name"), text: $categoryName, systemName: "folder", forget: true, maxLength: 30)
                .foregroundStyle(Color("SecondaryTextColor"))
            
            ErrorMessageView(errorMessage: errorMessage, height: 20)
            
            HStack {
                Button(action: {
                    if categoryName.isEmpty {
                        errorMessage = String(localized: "Please enter a category")
                    } else {
                        Task {
                            _ = await budgetfb.editCategory(
                                oldName: category.name,
                                newName: categoryName,
                                type: category.type
                            )
                            await onComplete()
                            isPresented = false
                        }
                    }
                }) {
                    ButtonView(buttontext: String(localized: "Save"), maxWidth: 150, incomeButton: true)
                }
            }
        }
        .frame(width: UIScreen.main.bounds.width * 0.85) // Make width relative to screen size
        .frame(height: 270)
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: colorScheme == .dark ? [
                    Color(.darkGray), Color(.black)
                ] : [
                    Color(red: 229/255, green: 237/255, blue: 235/255),
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
        .onAppear {
            categoryName = category.name
        }
    }
}

#Preview {
    EditCategoryView(
        isPresented: .constant(true), budgetfb: BudgetFB(),
        category: EditingCategory(
            name: "Food",
            type: .income
        ),
        onComplete: {
           print("Categories reloaded")
           await Task.yield()
       }
    )
}
