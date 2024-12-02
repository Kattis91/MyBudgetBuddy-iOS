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
                    Text("Simplify your budget, simplify your life.")
                    Image("Save")
                        .resizable() // Makes the image resizable
                        .frame(width: 200, height: 200)
                }
                
                Spacer()
                
                VStack {
                    
                    Text("Welcome! Let's get started!")
                        .font(.title2)
                        .fontWeight(.regular)
                        .padding()
                    
                    NavigationLink(destination: LoginView()) {
                        ButtonView(buttontext: "Sign in")
                    }
                    
                    NavigationLink(destination: RegisterView()) {
                        ButtonView(buttontext: "Create an account")
                    }
                }
                .padding(.bottom, 100)
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .background(Color.orange.opacity(0.2))
        }
    }
    
}

#Preview {
    UnloggedView()
}
