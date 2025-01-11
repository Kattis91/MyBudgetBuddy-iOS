//
//  EditCategorySheet.swift
//  MyBudget
//
//  Created by Katya Durneva Svedmark on 2025-01-11.
//

import SwiftUI

struct EditCategorySheet: View {
    
    @Environment(\.dismiss) var dismiss
    let originalName: String
    let type: CategoryType
    let onSave: (String) -> Void
    
    @State private var categoryName = ""
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Category Name", text: $categoryName)
            }
            .navigationTitle("Edit Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(categoryName)
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            categoryName = originalName
        }
    }
}

#Preview {
    EditCategorySheet(
        originalName: "Groceries",
        type: .income,
        onSave: { newName in
            print("New name: \(newName)")
        }
    )
}
