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
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Text(errorMessage)
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
    
                    TextField("Email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                        .onChange(of: email) {
                            errorMessage = ""
                        }
                    
                    if budgetfb.loginerror != nil {
                        Text(budgetfb.loginerror!)
                    }
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                        .onChange(of: password) {
                            errorMessage = ""
                        }
                    
                    HStack {
                        Spacer()
                        Button(action: {
                            email = ""
                            errorMessage = ""
                            showForgotPassword.toggle()
                        }) {
                            Text("Forgot password")
                        }
                    }
                    .padding(.horizontal)
                    
                    Button(action: {
                        if let validationError = ValidationUtils.validateInputs(email: email, password: password) {
                            errorMessage = validationError
                        } else {
                            budgetfb.userLogin(email: email, password: password)
                        }
                    }) {
                        ButtonView(buttontext: "Sign in")
                    }
                    
                }
                .padding(.bottom, 100)
            }
            if showForgotPassword {
                ForgotPasswordView(isPresented: $showForgotPassword)
                    .frame(width: 300, height: 200)
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(radius: 10)
            }
        }
    }
}

#Preview {
    LoginView()
}
