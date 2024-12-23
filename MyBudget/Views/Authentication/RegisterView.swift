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
    @State var errorMessage = ""
    
    var body: some View {
        VStack {
            
            VStack {
                
                Image("Save")
                    .resizable()
                    .frame(width: 120, height: 120)
                    .padding(.bottom, 30)
                
                Text("Nice to have you here! Let's dive in!")
                    .foregroundStyle(Color("TextColor"))
                    .font(.title3)
                
                ErrorMessageView(errorMessage: errorMessage)
                
                CustomTextFieldView(placeholder: "Email", text: $email, onChange: {
                    errorMessage = ""
                }, leadingPadding: 45, trailingPadding: 45, systemName: "envelope")
                
                CustomTextFieldView(placeholder: "Password", text: $password, isSecure: true, onChange: {
                    errorMessage = ""
                }, leadingPadding: 45, trailingPadding: 45, systemName: "lock")
                
                CustomTextFieldView(placeholder: "Confirm Password", text: $confirmPassword, isSecure: true, onChange: {
                    errorMessage = ""
                }, leadingPadding: 45, trailingPadding: 45, systemName: "lock")
                
                Button(action: {
                    if let validationError = ValidationUtils.validateInputs(email: email, password: password, confirmPassword: confirmPassword) {
                        errorMessage = validationError
                    } else {
                        budgetfb.userRegister(email: email, password: password) { firebaseError in
                            errorMessage = firebaseError ?? "" // Default to empty string if no Firebase error
                        }
                    }
                }) {
                    ButtonView(buttontext: "Sign Up".uppercased(), maxWidth: 150)
                }
                .padding(.bottom, 100)
            }
        }
    }
}

#Preview {
    RegisterView()
}
