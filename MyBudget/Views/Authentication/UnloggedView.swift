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
                    Text("BudgetBuddy")
                        .font(.largeTitle)
                        .padding(.top, 50)
                        .foregroundStyle(Color("TextColor"))
                    Text("Managing money shouldn’t be hard")
                        .foregroundStyle(Color("TextColor"))
                        .font(.title3)
                        .multilineTextAlignment(.leading)
                    Image("Save")
                        .resizable() // Makes the image resizable
                        .frame(width: 200, height: 200)
                        .padding()
                }
                
                Spacer()
                
                VStack {
                    
                    Text("Welcome! Let's get started!")
                        .font(.title2)
                        .fontWeight(.regular)
                        .padding()
                        .foregroundStyle(Color("TextColor"))
                    
                    NavigationLink(destination: LoginView()) {
                        ButtonView(buttontext: "Sign in", maxWidth: 100)
                    }
                    
                    NavigationLink(destination: RegisterView()) {
                        ButtonView(buttontext: "Create an account", maxWidth: 200)
                    }
                }
                .padding(.bottom, 100)
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .background(Color.orange.opacity(0.1))
        }
    }
    
}

#Preview {
    UnloggedView()
}
