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
            
            Text("Reset Password")
                .padding()
                .font(.headline)
            
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
                .onChange(of: email) {
                    errorMessage = ""
                }
            
            VStack (alignment: .leading) {
                HStack {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.leading)
                    Spacer() // Pushes the text to the left
                }
                .padding(.horizontal)
            }
            
            HStack {
                Button(action: {
                    if let validationError = ValidationUtils.validateReset(email: email) {
                        errorMessage = validationError
                    } else {
                        budgetfb.forgotPassword(email: email)
                    }
                }) {
                    ButtonView(buttontext: "Send reset link")
                }
                
                Button(action: {
                    isPresented = false
                }) {
                    Text("Back to Login")
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 200)
        .background(Color.yellow)
    }
}

#Preview {
    ForgotPasswordView(isPresented: .constant(true))
}
