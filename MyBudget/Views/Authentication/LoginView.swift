//
//  LoginView.swift
//  MyBudget
//
//  Created by Katya Durneva Svedmark on 2024-12-01.
//

import SwiftUI

struct LoginView: View {
    
    @State var budgetfb = BudgetFB()
    
    @State var email = ""
    @State var password = ""

    @State private var emailErrorMessage = ""
    @State private var passwordErrorMessage = ""
    @State private var generalErrorMessage = ""
    
    @State var showForgotPassword = false
    
    var body: some View {
        ZStack {
            if !showForgotPassword {
                VStack {
                    
                    Image("Save")
                        .resizable()
                        .frame(width: 170, height: 170)
                        .padding(.bottom, 70)
                    
                    CustomTextFieldView(placeholder: "Email", text: $email, onChange: {
                            emailErrorMessage = ""
                    }, leadingPadding: 45, trailingPadding: 45, systemName: "envelope", maxLength: 50)
                    
                    ErrorMessageView(errorMessage: emailErrorMessage, height: 15, padding: 30)
                    
                    CustomTextFieldView(placeholder: "Password", text: $password, isSecure: true, onChange: {
                        passwordErrorMessage = ""
                    }, leadingPadding: 45, trailingPadding: 45, systemName: "lock")
                    
                    ErrorMessageView(errorMessage: passwordErrorMessage, height: 15, padding: 30)
                  
                    HStack {
                        Spacer()
                        Button(action: {
                            email = ""
                            password = ""
                            emailErrorMessage = ""
                            passwordErrorMessage = ""
                            generalErrorMessage = ""
                            withAnimation(.spring()) {
                                showForgotPassword.toggle()
                            }
                        }) {
                            Text("Forgot password?")
                        }
                    }
                    .padding(.trailing, 45)
                    
                    ErrorMessageView(errorMessage: generalErrorMessage, padding: 30)
                    
                    Button(action: {
                        emailErrorMessage = ValidationUtils.validateEmail(email: email) ?? ""
                        passwordErrorMessage = ValidationUtils.validatePassword(password: password) ?? ""
                        
                        if emailErrorMessage.isEmpty && passwordErrorMessage.isEmpty {
                            budgetfb.userLogin(email: email, password: password) { firebaseError in
                                generalErrorMessage = firebaseError ?? ""
                            }
                        }
                    }) {
                        ButtonView(buttontext: "Sign in".uppercased(), maxWidth: 150, expenseButton: true)
                    }
                }
            }
            if showForgotPassword {
                ForgotPasswordView(isPresented: $showForgotPassword, deletingAccountReset: false)
                    .navigationBarBackButtonHidden(true)
                    .frame(height: 330)
                    .background(Color.white)
                    .padding(.horizontal, 24)
                    .cornerRadius(12)
            }
        }
    }
}

#Preview {
    LoginView()
}
