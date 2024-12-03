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
                    Text("WELCOME back! Let's dive in!")
                        .padding()
                        .foregroundStyle(Color("TextColor"))
                        .font(.title3)
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Text(errorMessage)
                                .padding(.horizontal)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.trailing)
                                .frame(height: 20) // Fixed height to reserve space
                                .opacity(errorMessage.isEmpty ? 0 : 1) // Fade out
                                .offset(x: errorMessage.isEmpty ? 20 : 0) // Slide to the right when disappearing
                                .animation(.easeInOut, value: errorMessage.isEmpty)
                            Spacer()
                        }
                    }
                    .padding(.horizontal)
                    
                    CustomTextFieldView(placeholder: "Email", text: $email, onChange: {
                            errorMessage = ""
                        })
                    
                    CustomTextFieldView(placeholder: "Password", text: $password, isSecure: true, onChange: {
                        errorMessage = ""
                    })
                    
                    if budgetfb.loginerror != nil {
                        Text(budgetfb.loginerror!)
                    }
                    
                    Button(action: {
                        if let validationError = ValidationUtils.validateInputs(email: email, password: password) {
                            errorMessage = validationError
                        } else {
                            budgetfb.userLogin(email: email, password: password)
                        }
                    }) {
                        ButtonView(buttontext: "Sign in".uppercased())
                    }
                    
                    HStack {
                    
                        Button(action: {
                            email = ""
                            errorMessage = ""
                            showForgotPassword.toggle()
                        }) {
                            Text("Forgot password?")
                                .foregroundStyle(Color.buttonsBackground)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 8)
                                .background(Color.white)
                                .cornerRadius(12)
                                .fontWeight(.medium)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 10)
                    
                }
                .padding(.bottom, 100)
            }
            if showForgotPassword {
                ForgotPasswordView(isPresented: $showForgotPassword)
                    .frame(width: 300, height: 250)
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(radius: 10)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.orange.opacity(0.2))
    }
}

#Preview {
    LoginView()
}
