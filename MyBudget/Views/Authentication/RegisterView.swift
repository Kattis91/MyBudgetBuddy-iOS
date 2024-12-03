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
                Text("Nice to have you here! Let's dive in!")
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
                
                CustomTextFieldView(placeholder: "Confirm Password", text: $confirmPassword, isSecure: true, onChange: {
                    errorMessage = ""
                })
                
                Button(action: {
                    if let validationError = ValidationUtils.validateInputs(email: email, password: password, confirmPassword: confirmPassword) {
                        errorMessage = validationError
                    } else {
                        budgetfb.userRegister(email: email, password: password, confirmPassword: confirmPassword)
                    }
                }) {
                    ButtonView(buttontext: "Create an account")
                }
            }
            .padding(.bottom, 100)
        }
        .frame(maxHeight: .infinity)
        .background(Color.orange.opacity(0.2))
    }
}

#Preview {
    RegisterView()
}
