//
//  ForgotPasswordView.swift
//  MyBudget
//
//  Created by Katya Durneva Svedmark on 2024-12-01.
//

import SwiftUI

struct ForgotPasswordView: View {
    
    @Binding var isPresented: Bool
    
    @State var budgetfb = BudgetFB()
    
    @State var email = ""
    @State var errorMessage = ""
    @State var successMessage: String?
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        
        VStack {
            
            HStack {
                Spacer()
                Button(action: {
                    isPresented = false
                }) {
                    Text("x")
                        .font(.title)
                        .foregroundStyle(.red)
                        .fontWeight(.bold)
                }
            }
            .padding(.horizontal)
            
            
            Text("Reset Password")
                .padding(.bottom, 35.0)
                .font(.title2)
            
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal, 24)
                .onChange(of: email) {
                    errorMessage = ""
                }
            
            VStack {
                if errorMessage != "" {
                    ErrorMessageView(errorMessage: errorMessage)
                } else if let successMessage = successMessage {
                    Text(successMessage)
                        .foregroundColor(.blue)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }
            .frame(height: 50)
            
            HStack {
                Button(action: {
                    if let validationError = ValidationUtils.validateReset(email: email) {
                        errorMessage = validationError
                        successMessage = nil
                    } else {
                        budgetfb.forgotPassword(email: email) { firebaseError in
                            if let firebaseError = firebaseError {
                                errorMessage = firebaseError
                                successMessage = nil
                            } else {
                                successMessage = "If the email you provided is registered, we've sent a reset link to your inbox."
                                email = ""
                                errorMessage = firebaseError ?? "" // Clear error on success
                            }
                        }
                    }
                }) {
                    ButtonView(buttontext: "Send reset link", maxWidth: 180)
                }
            }
        }
        .padding(.bottom, 10)
        .frame(maxWidth: .infinity)
        .frame(height: 280)
        .background(Color.resetPasswordBox)
    }
}

#Preview {
    ForgotPasswordView(isPresented: .constant(true))
}
