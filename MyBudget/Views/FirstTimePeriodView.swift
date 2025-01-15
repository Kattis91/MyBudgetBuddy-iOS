//
//  FirstTimePeriodView.swift
//  MyBudget
//
//  Created by Katya Durneva Svedmark on 2025-01-15.
//

import SwiftUI

struct FirstTimePeriodView: View {
    
    @State var showingNewPeriod = false
    @EnvironmentObject var budgetManager: BudgetManager
    var budgetfb = BudgetFB()
    
    var body: some View {
        
        ZStack {
            NavigationStack {
                if !showingNewPeriod {
                    
                    VStack(spacing: 20) {
                        
                        Image("Save")
                            .resizable()
                            .frame(width: 180, height: 180)
                            .padding(.bottom, 30)
                        
                        Text("Welcome to MyBudgetBuddy!")
                            .font(.title)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        
                        Text("To start tracking your budget, you'll need to create your first budget period.")
                            .multilineTextAlignment(.center)
                        
                        Button(action: {
                            showingNewPeriod.toggle()
                        }) {
                            ButtonView(buttontext: "Create Budget Period")
                        }
                        .padding(.horizontal)
                    }
                    .padding()
                }
                
                if showingNewPeriod {
                    NewBudgetPeriodView(isPresented: $showingNewPeriod, isLandingPage: true)
                        .navigationBarBackButtonHidden(true)
                        .frame(height: 300)
                        .background(Color.white)
                        .padding(.horizontal, 24)
                        .cornerRadius(12)
                        .shadow(radius: 10)
                }
            }
        }
    }
}

#Preview {
    FirstTimePeriodView()
        .environmentObject(BudgetManager())
}
