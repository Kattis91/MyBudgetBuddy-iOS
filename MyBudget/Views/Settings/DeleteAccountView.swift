//
//  DeleteAccountView.swift
//  MyBudget
//
//  Created by Katya Durneva Svedmark on 2025-02-21.
//

import SwiftUI

struct DeleteAccountView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showingConfirmation = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        
        ZStack {
            VStack(spacing: 20) {
                VStack(spacing: 10) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                        .font(.largeTitle)
                    
                    Text("Warning: Account Deletion")
                        .font(.headline)
                        .foregroundColor(.orange)
                    
                    Text("This action cannot be undone. All your data will be permanently deleted.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.gray)
                }
                
                VStack(spacing: 15) {
                    
                    Button(action: {
                        withAnimation(.spring()) {
                            showingConfirmation.toggle()
                        }
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
            if showingConfirmation {
                PasswordConfirmationView(isPresented: $showingConfirmation)
                    .navigationBarBackButtonHidden(true)
                    .frame(height: 350)
                    .background(Color.white)
                    .padding(.horizontal, 24)
                    .cornerRadius(12)
            }
        }
    }
}

#Preview {
    DeleteAccountView()
}
