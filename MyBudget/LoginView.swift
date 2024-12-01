//
//  LoginView.swift
//  MyBudget
//
//  Created by Katya Durneva Svedmark on 2024-12-01.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct LoginView: View {
    
    @State var email = ""
    @State var password = ""
    
    var body: some View {
        VStack {
            Text("LOGIN")
            TextField("Email", text: $email)
            SecureField("Password", text: $password)
            
            Button(action: {
                Task {
                    await userLogin()
                }
            }) {
                Text("Login")
            }
            Button(action: {
                Task {
                    await userRegister()
                }
            }) {
                Text("Register")
            }
        }
        .padding()
    }
    
    func userLogin() async {
        do {
            try await Auth.auth().signIn(withEmail: email, password: password)
        } catch {
            print("Fel Login")
        }
    }
    
    func userRegister() async {
        do {
            let regResult = try await Auth.auth().createUser(withEmail: email, password: password)
        } catch {
            print("Fel Reg")
        }
    }
}

#Preview {
    LoginView()
}
