//
//  NewCategoryView.swift
//  MyBudget
//
//  Created by Katya Durneva Svedmark on 2025-01-20.
//

import SwiftUI

struct NewCategoryView: View {
    
    @Binding var isPresented: Bool
    @State var budgetfb: BudgetFB
    let categoryType: CategoryType 
    let onComplete: () async -> Void
    
    @State private var categoryName = ""
    @State private var errorMessage = ""
    
    var body: some View {
        VStack {
            // Close button
            HStack {
                Spacer()
                Button(action: {
                    isPresented = false
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.red)
                }
            }
            
            Text("Add Category")
                .font(.title3)
                .padding(.vertical, 15)
                .foregroundStyle(Color("SecondaryTextColor"))
            
            // Input field
            CustomTextFieldView(
                placeholder: String(localized: "Category name"),
                text: $categoryName,
                systemName: "folder",
                forget: true
            )
            
            // Error message
            if !errorMessage.isEmpty {
                ErrorMessageView(errorMessage: errorMessage, height: 20)
            }
            
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
                    ButtonView(buttontext: String(localized: "Save"), maxWidth: 150)
                }
            }
        }
        .frame(width: UIScreen.main.bounds.width * 0.85) // Relative width
        .frame(height: 270)
        .padding()
        .background(Color("TabColor"))
        .cornerRadius(12)
        .shadow(radius: 10)
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
