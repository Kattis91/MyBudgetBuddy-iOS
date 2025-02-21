//
//  DeleteAccountView.swift
//  MyBudget
//
//  Created by Katya Durneva Svedmark on 2025-02-21.
//

import SwiftUI

struct DeleteAccountView: View {
    @Environment(\.dismiss) var dismiss
    @State private var password = ""
    @State private var confirmationText = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(spacing: 10) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(Color("ButtonsBackground"))
                        .font(.largeTitle)
                    
                    Text("Warning: Account Deletion")
                        .font(.headline)
                        .foregroundColor(Color("ButtonsBackground"))
                    
                    Text("This action cannot be undone. All your data will be permanently deleted.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.gray)
                }
                
                VStack(spacing: 15) {
                
                    Button(action: {
                        
                    }) {
                        ButtonView(buttontext: "Delete with password", maxWidth: 250, expenseButton: true)
                    }
                    
                    Button(action: {
                        
                    }) {
                        ButtonView(buttontext: "Forgot password?", maxWidth: 250, expenseButton: true)
                    }
                }
            }
            .padding()
            .navigationTitle("Delete Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    DeleteAccountView()
}
