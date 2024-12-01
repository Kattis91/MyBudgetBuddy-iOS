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
            Text("LOGIN")
            
            if budgetfb.loginerror != nil {
               Text(budgetfb.loginerror!)
           }
            
            TextField("Email", text: $email)
            SecureField("Password", text: $password)
            
            Button(action: {
                budgetfb.userLogin(email: email, password: password)
            }) {
                Text("Login")
            }
            Button(action: {
                budgetfb.userRegister(email: email, password: password)
            }) {
                Text("Register")
            }
        }
        .padding()
    }
}

#Preview {
    LoginView()
}
