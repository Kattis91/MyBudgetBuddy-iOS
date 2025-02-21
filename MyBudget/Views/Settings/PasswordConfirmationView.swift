//
//  PasswordConfirmationView.swift
//  MyBudget
//
//  Created by Katya Durneva Svedmark on 2025-02-21.
//

import SwiftUI

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
}

#Preview {
    PasswordConfirmationView(isPresented: .constant(true))
}
