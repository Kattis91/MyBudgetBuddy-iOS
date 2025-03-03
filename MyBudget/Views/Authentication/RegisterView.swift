//
//  RegisterView.swift
//  MyBudget
//
//  Created by Katya Durneva Svedmark on 2024-12-01.
//

import SwiftUI

struct RegisterView: View {
    
    @State var budgetfb = BudgetFB()
    
    @State var email = ""
    @State var password = ""
    @State var confirmPassword = ""
    
    @State private var emailErrorMessage = ""
    @State private var passwordErrorMessage = ""
    @State private var confirmPasswordErrorMessage = ""
    @State private var generalErrorMessage = ""
    
    var body: some View {
        ScrollView {
            VStack {
                
                VStack {
                    
                    Image("Save")
                        .resizable()
                        .frame(width: 170, height: 170)
                        .padding(.bottom, 70)
                    
                    CustomTextFieldView(placeholder: "Email", text: $email, onChange: {
                        emailErrorMessage = ""
                    }, leadingPadding: 45, trailingPadding: 45, systemName: "envelope", maxLength: 50, forceLightMode: true)
                    
                    ErrorMessageView(errorMessage: emailErrorMessage, height: 15, padding: 30)
                    
                    CustomTextFieldView(placeholder: "Password", text: $password, isSecure: true, onChange: {
                        passwordErrorMessage = ""
                    }, leadingPadding: 45, trailingPadding: 45, systemName: "lock", forceLightMode: true)
                    
                    ErrorMessageView(errorMessage: passwordErrorMessage, height: 15, padding: 30)
                    
                    CustomTextFieldView(placeholder: "Confirm Password", text: $confirmPassword, isSecure: true, onChange: {
                        confirmPasswordErrorMessage = ""
                    }, leadingPadding: 45, trailingPadding: 45, systemName: "lock", forceLightMode: true)
                    
                    ErrorMessageView(errorMessage: confirmPasswordErrorMessage, height: 15, padding: 30)
                    
                    ErrorMessageView(errorMessage: generalErrorMessage, padding: 30)
                    
                    Button(action: {
                        emailErrorMessage = ValidationUtils.validateEmail(email: email) ?? ""
                        passwordErrorMessage = ValidationUtils.validatePassword(password: password) ?? ""
                        confirmPasswordErrorMessage = ValidationUtils.validateConfirmPassword(password: password, confirmPassword: confirmPassword) ?? ""
                        
                        if emailErrorMessage.isEmpty && passwordErrorMessage.isEmpty && confirmPasswordErrorMessage.isEmpty {
                            budgetfb.userRegister(email: email, password: password) { firebaseError in
                                generalErrorMessage = firebaseError ?? ""
                            }
                        }
                    }) {
                        ButtonView(buttontext: "Sign Up".uppercased(), maxWidth: 150, expenseButton: true)
                            .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                    }
                }
            }
        }
    }
}

#Preview {
    RegisterView()
}
