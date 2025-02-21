//
//  PasswordConfirmationView.swift
//  MyBudget
//
//  Created by Katya Durneva Svedmark on 2025-02-21.
//

import SwiftUI
import FirebaseAuth
import Firebase

struct PasswordConfirmationView: View {
    
    @State private var showingPasswordOption = false
    @State private var showingConfirmation = false
    @State private var password = ""
    @State private var confirmationText = ""
    @Binding var isPresented: Bool
    
    
    var body: some View {
        
        VStack(spacing: 20) {
            
            HStack {
                Spacer()
                Button(action: {
                    isPresented = false
                }) {
                    Image(systemName: "xmark")
                        .foregroundStyle(.red)
                }
            }
            .padding(.horizontal)
            .padding(.top, 10)
            
            Text("Confirm Deletion")
                .font(.title2)
                .foregroundStyle(Color("SecondaryTextColor"))
                .padding(.bottom, 15)
            
            CustomTextFieldView(placeholder: "Type DELETE to confirm", text: $confirmationText, systemName: "trash.circle")
            
            CustomTextFieldView(placeholder: "Current Password", text: $password, isSecure: true, systemName: "lock")
            
            Button("Delete Account") {
                deleteAccount(password: password)
            }
            .disabled(confirmationText != "DELETE" || password.isEmpty)
            .buttonStyle(.borderedProminent)
            .tint(.red)
            .padding(.top, 20)
        }
        .padding(.bottom, 50)
        .frame(maxWidth: .infinity)
        .frame(height: 350)
        .background(Color("TabColor"))
        .cornerRadius(12)
    }
    
    private func deleteAccount(password: String) {
        guard let user = Auth.auth().currentUser else {
            print("No user is signed in.")
            return
        }
        
        let credential = EmailAuthProvider.credential(withEmail: user.email ?? "", password: password)
        
        user.reauthenticate(with: credential) { authResult, error in
            if let error = error {
                print("Re-authentication failed: \(error.localizedDescription)")
                return
            }
            
            // Delete user data from Firebase Realtime Database
            let userId = user.uid
            let databaseRef = Database.database().reference()
            
            // Paths to delete
            let paths = [
                "budgetPeriods/\(userId)",
                "categories/\(userId)",
                "historicalPeriods/\(userId)",
                "invoices/\(userId)",
                "userTokens/\(userId)"
            ]
            
            let group = DispatchGroup()
            
            for path in paths {
                group.enter()
                databaseRef.child(path).removeValue { error, _ in
                    if let error = error {
                        print("Failed to delete data at \(path): \(error.localizedDescription)")
                    }
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                // All data deleted, now delete the user account
                user.delete { error in
                    if let error = error {
                        print("Account deletion failed: \(error.localizedDescription)")
                    } else {
                        print("Account successfully deleted.")
                        isPresented = false // Dismiss the view
                    }
                }
            }
        }
    }
}

#Preview {
    PasswordConfirmationView(isPresented: .constant(true))
}
