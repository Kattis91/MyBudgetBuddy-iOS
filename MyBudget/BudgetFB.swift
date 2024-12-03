//
//  BudgetFB.swift
//  MyBudget
//
//  Created by Katya Durneva Svedmark on 2024-12-01.
//

import Foundation
import Firebase
import FirebaseAuth

@Observable class BudgetFB {
    
    var loginerror : String?
    
    func userLogin(email : String, password : String) {
        Task {
            do {
                try await Auth.auth().signIn(withEmail: email, password: password)
            } catch {
                print("Fel Login")
                loginerror = "Error login"
            }
        }
    }
    
    func userRegister(email : String, password : String, confirmPassword : String) {
        Task {
            do {
                let regResult = try await Auth.auth().createUser(withEmail: email, password: password)
            } catch {
                print("Fel Reg")
                loginerror = "Error reg"
            }
        }
    }
    
    func userLogout() {
        do {
            try Auth.auth().signOut()
        } catch {
            
        }
    }
    
    func forgotPassword(email : String) {
        Task {
            do {
                try await Auth.auth().sendPasswordReset(withEmail: email)
                print("Sent!")
            } catch {
                print("Fel Forgot")
                loginerror = "Error forgot"
            }
        }
    }
}
