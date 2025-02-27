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
    @State var showForgotPassword = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                if !showingConfirmation && !showForgotPassword {
                    
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
                                withAnimation(.spring()) {
                                    showForgotPassword.toggle()
                                }
                            }) {
                                ButtonView(buttontext: "Forgot password?", maxWidth: 250, expenseButton: true)
                            }
                        }
                    }
                    .padding()
                    .navigationTitle("Delete Account")
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
                }
                if showingConfirmation {
                    PasswordConfirmationView(isPresented: $showingConfirmation)
                        .navigationBarBackButtonHidden(true)
                        .frame(height: 350)
                        .padding(.horizontal, 24)
                        .cornerRadius(12)
                }
                if showForgotPassword {
                    ForgotPasswordView(isPresented: $showForgotPassword, deletingAccountReset: true)
                        .navigationBarBackButtonHidden(true)
                        .frame(height: 330)
                        .padding(.horizontal, 24)
                        .cornerRadius(12)
                }
            }
        }
    }
}

#Preview {
    DeleteAccountView()
}
