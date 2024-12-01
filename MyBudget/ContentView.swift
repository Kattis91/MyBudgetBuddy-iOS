//
//  ContentView.swift
//  MyBudget
//
//  Created by Katya Durneva Svedmark on 2024-12-01.
//

import SwiftUI

import FirebaseAuth


struct ContentView: View {
    
    @State var isLoggedIn : Bool?
    
    var body: some View {
      
        VStack {
            if isLoggedIn == true {
                HomeView()
            }
            if isLoggedIn == false {
                LoginView()
            }
        }
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
}
