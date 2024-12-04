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
            
            ErrorMessageView(errorMessage: errorMessage)
            
            HStack {
                Button(action: {
                    if let validationError = ValidationUtils.validateReset(email: email) {
                        errorMessage = validationError
                    } else {
                        budgetfb.forgotPassword(email: email)
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
