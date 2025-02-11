//
//  EditCategoryView.swift
//  MyBudget
//
//  Created by Katya Durneva Svedmark on 2025-01-12.
//

import SwiftUI

struct EditCategoryView: View {
    
    @Binding var isPresented: Bool
    @State var budgetfb: BudgetFB
    let category: EditingCategory
    let onComplete: () async -> Void
    
    @State private var categoryName = ""
    
    var body: some View {
        
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    isPresented = false
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.red)
                }
            }
            
            Text("Editing Category")
                .font(.title3)
                .padding(.vertical, 15)
                .foregroundStyle(Color("SecondaryTextColor"))
            
            CustomTextFieldView(placeholder: String(localized: "Category name"), text: $categoryName, systemName: "folder", forget: true, maxLength: 30)
                .foregroundStyle(Color("SecondaryTextColor"))
            
            HStack {
                Button(action: {
                    Task {
                        _ = await budgetfb.editCategory(
                            oldName: category.name,
                            newName: categoryName,
                            type: category.type
                        )
                        await onComplete()
                        isPresented = false
                    }
                }) {
                    ButtonView(buttontext: String(localized: "Save"), maxWidth: 150)
                }
            }
        }
        .frame(width: UIScreen.main.bounds.width * 0.85) // Make width relative to screen size
        .frame(height: 270)
        .padding()
        .background(Color("TabColor"))
        .cornerRadius(12)
        .shadow(radius: 10)
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
