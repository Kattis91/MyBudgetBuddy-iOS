//
//  HomeView.swift
//  MyBudget
//
//  Created by Katya Durneva Svedmark on 2024-12-01.
//

import SwiftUI
import FirebaseAuth

struct HomeView: View {
    
    @State var budgetfb = BudgetFB()
    
    var body: some View {
        
        VStack {
            Button(action: {
              budgetfb.userLogout()
            }) {
                Text("Sign Out")
            }
        }
    }
}

#Preview {
    HomeView()
}
