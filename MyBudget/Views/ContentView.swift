//
//  ContentView.swift
//  MyBudget
//
//  Created by Katya Durneva Svedmark on 2024-12-01.
//

import SwiftUI

import FirebaseAuth


struct ContentView: View {
    
    @EnvironmentObject var budgetManager: BudgetManager 
    @State var isLoggedIn : Bool?
    
    var body: some View {
      
        VStack {
            if isLoggedIn == true {
                HomeView()
            }
            if isLoggedIn == false {
                UnloggedView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear() {
            Auth.auth().addStateDidChangeListener { auth, user in
                print("USER CHANGE")
                
                if Auth.auth().currentUser == nil {
                    isLoggedIn = false
                } else {
                    isLoggedIn = true
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(BudgetManager())
}
