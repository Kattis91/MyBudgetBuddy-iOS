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
                
                if budgetfb.loginerror != nil {
                    Text(budgetfb.loginerror!)
                }
                
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                Button(action: {
                    budgetfb.userLogin(email: email, password: password)
                }) {
                    ButtonView(buttontext: "Sign in")
                }
               
                
                Button(action: {
                    budgetfb.userRegister(email: email, password: password)
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
