//
//  UnloggedView.swift
//  MyBudget
//
//  Created by Katya Durneva Svedmark on 2024-12-01.
//

import SwiftUI

struct UnloggedView: View {
    
    @State var budgetfb = BudgetFB()
    
    @State var email = ""
    @State var password = ""
    @State var errorMessage = ""
    
    var body: some View {
        
        NavigationStack {
            VStack {
                VStack {
                    Image("Save")
                        .resizable() // Makes the image resizable
                        .frame(width: 200, height: 200)
                        .padding()
                        .padding(.top, 70)
                    Text("MyBudgetBuddy")
                        .font(.largeTitle)
                        .padding(.top, 50)
                        .foregroundStyle(Color("PrimaryTextColor"))
                    Text("Managing money shouldn’t be hard")
                        .foregroundStyle(Color("PrimaryTextColor"))
                        .font(.title3)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: 280)
                        .multilineTextAlignment(.center)
                        .padding()
                }
                
                Spacer()
                
                VStack {
                    
                    NavigationLink(destination: LoginView()) {
                        ButtonView(buttontext: "Sign in", maxWidth: 180, expenseButton: true)
                    }
                    
                    NavigationLink(destination: RegisterView()) {
                        ButtonView(buttontext: "Create an account", maxWidth: 180, expenseButton: true)
                    }
                }
                .padding(.bottom, 100)
                
                Spacer()
            }
        }
    }
    
}

#Preview {
    UnloggedView()
}
