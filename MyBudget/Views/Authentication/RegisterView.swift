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
            
                TextField("Email", text: $email)
                    .frame(height: 45)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(.horizontal)
                    .background(Color.white)
                    .cornerRadius(12)
                    .padding([.horizontal], 24)
                    .padding(.bottom, 3)
                    .onChange(of: email) {
                        errorMessage = ""
                    }
                
                if budgetfb.loginerror != nil {
                    Text(budgetfb.loginerror!)
                }
                
                SecureField("Password", text: $password)
                    .frame(height: 45)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(.horizontal)
                    .background(Color.white)
                    .cornerRadius(12)
                    .padding([.horizontal], 24)
                    .padding(.bottom, 3)
                    .onChange(of: password) {
                        errorMessage = ""
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
        .frame(maxHeight: .infinity)
        .background(Color.orange.opacity(0.2))
    }
}

#Preview {
    RegisterView()
}
