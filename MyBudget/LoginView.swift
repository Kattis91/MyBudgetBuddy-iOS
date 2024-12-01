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
    
    var body: some View {
        VStack {
            VStack {
                Text("MyBudget")
                    .font(.title)
                    .padding(.top, 50)
                Text("Simplify your budget, simplify your life.")
                Image("Save")
                    .resizable() // Makes the image resizable
                    .frame(width: 200, height: 200)
            }
            
            Spacer()
           
            VStack {
                Text("WELCOME! Let's dive in!")
            
                
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                if budgetfb.loginerror != nil {
                    Text(budgetfb.loginerror!)
                }
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
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
                    if !ValidationUtils.isNotEmpty(email) {
                        errorMessage = "Email field cannot be empty."
                    } else if !ValidationUtils.isValidEmail(email) {
                        errorMessage = "Invalid email format."
                    } else if !ValidationUtils.isValidPassword(password) {
                        errorMessage = "Password must be at least 6 characters."
                    } else {
                        budgetfb.userLogin(email: email, password: password)
                    }
                }) {
                    ButtonView(buttontext: "Sign in")
                }
               
                
                Button(action: {
                    if !ValidationUtils.isNotEmpty(email) {
                        errorMessage = "Email field cannot be empty."
                    } else if !ValidationUtils.isValidEmail(email) {
                        errorMessage = "Invalid email format."
                    } else if !ValidationUtils.isValidPassword(password) {
                        errorMessage = "Password must be at least 6 characters."
                    } else {
                        budgetfb.userRegister(email: email, password: password)
                    }
                }) {
                    ButtonView(buttontext: "Create an account")
                }
                
            }
            .padding(.bottom, 100)
            
            Spacer()
        }
        .padding()
    }
    
}

#Preview {
    LoginView()
}
