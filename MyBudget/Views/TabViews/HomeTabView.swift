//
//  HomeTabView.swift
//  MyBudget
//
//  Created by Katya Durneva Svedmark on 2024-12-05.
//

import SwiftUI

struct HomeTabView: View {
    
    @State var budgetfb = BudgetFB()
    
    var body: some View {
        
        NavigationStack {
            VStack {
                Text("Here is a home page")
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    
                    Button(action: {
                        budgetfb.userLogout()
                    }) {
                        Text("Sign out")
                    }
                }
            }
        }
    }
    
}

#Preview {
    HomeTabView()
}
