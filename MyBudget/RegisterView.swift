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
    @State var errorMessage = ""
    
    var body: some View {
        VStack {
           
            VStack {
                Text("Nice to have you here! Let's dive in!")
            
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
                
                VStack (alignment: .leading) {
                    HStack {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.leading)
                        Spacer() // Pushes the text to the left
                    }
                    .padding(.horizontal)
                }
                
                Button(action: {
                    if let validationError = ValidationUtils.validateInputs(email: email, password: password) {
                        errorMessage = validationError
                    } else {
                        budgetfb.userLogin(email: email, password: password)
                    }
                }) {
                    ButtonView(buttontext: "Create an account")
                }
            }
            .padding(.bottom, 100)
        }
        .padding()
    }
}

#Preview {
    RegisterView()
}
