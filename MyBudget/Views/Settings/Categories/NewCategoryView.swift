//
//  NewCategoryView.swift
//  MyBudget
//
//  Created by Katya Durneva Svedmark on 2025-01-20.
//

import SwiftUI

struct NewCategoryView: View {
    
    @Environment(\.colorScheme) var colorScheme
    var isDarkMode: Bool {
        return colorScheme == .dark
    }
    
    @Binding var isPresented: Bool
    @State var budgetfb: BudgetFB
    let categoryType: CategoryType 
    let onComplete: () async -> Void
    
    @State private var categoryName = ""
    @State private var errorMessage = ""
    
    private func getCategoryTypeString() -> String {
        switch categoryType {
        case .income:
            return String(localized: "Add Income Category")
        case .fixedExpense:
            return String(localized: "Add Fixed Expense Category")
        case .variableExpense:
            return String(localized: "Add Variable Expense Category")
        }
    }
    
    var body: some View {
        VStack {
            // Close button
            HStack {
                Spacer()
                Button(action: {
                    isPresented = false
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(Color("ButtonsBackground"))
                }
            }
            
            Text(getCategoryTypeString())
                .font(.title3)
                .padding(.vertical, 25)
                .foregroundStyle(Color("PrimaryTextColor"))
            
            // Input field
            CustomTextFieldView(
                placeholder: String(localized: "Category name"),
                text: $categoryName,
                systemName: "folder",
                forget: true,
                maxLength: 30
            )
            
            ErrorMessageView(errorMessage: errorMessage, height: 20)
            
            HStack {
                Button(action: {
                    if categoryName.isEmpty {
                        errorMessage = String(localized: "Please enter a category")
                    } else {
                        Task {
                            _ = await budgetfb.addCategory(name: categoryName, type: categoryType)
                            await onComplete()
                            isPresented = false
                        }
                    }
                }) {
                    ButtonView(buttontext: String(localized: "Save"), maxWidth: 150, incomeButton: true)
                }
            }
        }
        .frame(width: UIScreen.main.bounds.width * 0.85) // Relative width
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
    }
}

#Preview {
    NewCategoryView(
        isPresented: .constant(true),
        budgetfb: BudgetFB(),
        categoryType: .income, // Example type
        onComplete: {
           print("Categories reloaded")
           await Task.yield()
       }
    )
}
