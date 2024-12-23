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
    @State var errorMessage = ""
    
    @State var showForgotPassword = false
    
    var body: some View {
        ZStack {
            if !showForgotPassword {
                VStack {
                    
                    Image("Save")
                        .resizable()
                        .frame(width: 120, height: 120)
                        .padding(.bottom, 30)
                    
                    Text("WELCOME back! Let's dive in!")
                        .padding()
                        .foregroundStyle(Color("TextColor"))
                        .font(.title3)
                    
                    ErrorMessageView(errorMessage: errorMessage)
                    
                    CustomTextFieldView(placeholder: "Email", text: $email, onChange: {
                            errorMessage = ""
                    }, leadingPadding: 45, trailingPadding: 45, systemName: "envelope")
                    
                    CustomTextFieldView(placeholder: "Password", text: $password, isSecure: true, onChange: {
                        errorMessage = ""
                    }, leadingPadding: 45, trailingPadding: 45, systemName: "lock")
                    
                    if budgetfb.loginerror != nil {
                        Text(budgetfb.loginerror!)
                    }
                    
                    HStack {
                        Spacer()
                        Button(action: {
                            email = ""
                            errorMessage = ""
                            showForgotPassword.toggle()
                        }) {
                            Text("Forgot password?")
                        }
                    }
                    .padding(.trailing, 45)
                    
                    Button(action: {
                        if let validationError = ValidationUtils.validateInputs(email: email, password: password) {
                            errorMessage = validationError
                        } else {
                            budgetfb.userLogin(email: email, password: password) { firebaseError in
                                errorMessage = firebaseError ?? "" // Default to empty string if no Firebase error
                            }
                        }
                    }) {
                        ButtonView(buttontext: "Sign in".uppercased(), maxWidth: 150)
                    }
                    
                }
                .padding(.bottom, 100)
            }
            if showForgotPassword {
                ForgotPasswordView(isPresented: $showForgotPassword)
                    .navigationBarBackButtonHidden(true)
                    .frame(height: 330)
                    .background(Color.white)
                    .padding(.horizontal, 24)
                    .cornerRadius(12)
                    .shadow(radius: 10)
                    .padding(.bottom, 100)
            }
        }
    }
}

#Preview {
    LoginView()
}
