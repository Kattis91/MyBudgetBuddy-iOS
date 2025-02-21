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
    
    @State var deletingAccountReset: Bool
    
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
                .foregroundStyle(Color("SecondaryTextColor"))
                .padding(.bottom, 50)
            
            CustomTextFieldView(placeholder: "Email", text: $email, onChange: {
                errorMessage = ""
            }, systemName: "envelope", forget: true, maxLength: 50)
            
            VStack {
                if errorMessage != "" {
                    ErrorMessageView(errorMessage: errorMessage)
                } else if let successMessage = successMessage {
                    Text(successMessage)
                        .foregroundColor(Color(red: 51/255, green: 143/255, blue: 133/255))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }
            .frame(height: 65)
        
            
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
                                successMessage = deletingAccountReset ? "Please check your email. Once password is reset, return to delete your account." : "If the email you provided is registered, we've sent a reset link to your inbox."
                                email = ""
                                errorMessage = firebaseError ?? "" // Clear error on success
                            }
                        }
                    }
                }) {
                    ButtonView(buttontext: "Send reset link", maxWidth: 180, expenseButton: true, topPadding: 0)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 330)
        .background(Color("TabColor"))
        .cornerRadius(12)
    }
}

#Preview {
    ForgotPasswordView(isPresented: .constant(true), deletingAccountReset: false)
}
