//
//  HomeView.swift
//  MyBudget
//
//  Created by Katya Durneva Svedmark on 2024-12-01.
//

import SwiftUI
import FirebaseAuth

struct HomeView: View {
    var body: some View {
        
        VStack {
            Button(action: {
                do {
                    try Auth.auth().signOut()
                } catch {
                    
                }
            }) {
                Text("Sign Out")
            }
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            
        }
    }
}

#Preview {
    HomeView()
}
