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
                    Image(systemName: "xmark")
                        .foregroundStyle(.red)
                }
            }
            .padding(.horizontal)
            
            
            Text("Reset Password")
                .font(.title2)
            
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
            
            CustomTextFieldView(placeholder: "Email", text: $email, onChange: {
                errorMessage = ""
            }, systemName: "envelope", forget: true)
        
            
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
                    ButtonView(buttontext: "Send reset link", maxWidth: 180, expenseButton:  true)
                }
            }
            .padding(.top, 25)
        }
        .padding(.bottom, 50)
        .frame(maxWidth: .infinity)
        .frame(height: 330)
        .background(Color("TabColor"))
    }
}

#Preview {
    ForgotPasswordView(isPresented: .constant(true))
}
