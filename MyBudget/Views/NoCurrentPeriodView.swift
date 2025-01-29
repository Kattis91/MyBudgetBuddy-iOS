//
//  NoCurrentPeriodView.swift
//  MyBudget
//
//  Created by Katya Durneva Svedmark on 2025-01-18.
//

import SwiftUI

struct NoCurrentPeriodView: View {
    
    @State var showingNewPeriod = false
    @EnvironmentObject var budgetManager: BudgetManager
    var budgetfb = BudgetFB()
    var onPeriodCreated: () -> Void
    @State var isFirstTime: Bool = false
    
    var body: some View {
        
        ZStack {
            NavigationStack {
                if !showingNewPeriod {
                    
                    VStack(spacing: 20) {
                        
                        Image("Save")
                            .resizable()
                            .frame(width: 180, height: 180)
                            .padding(.bottom, 30)
                        
                        Text(isFirstTime ? "Welcome to MyBudgetBuddy!" : "Your last budget period has ended")
                            .font(.title)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        
                        Text(isFirstTime ? "To start tracking your budget, you'll need to create your first budget period." : "Start a new period to continue tracking your budget")
                            .multilineTextAlignment(.center)
                        
                        Button(action: {
                            showingNewPeriod.toggle()
                        }) {
                            ButtonView(buttontext: isFirstTime ? "Create Budget Period" : "Start New Period", maxWidth: 230, expenseButton: true)
                        }
                        .padding(.horizontal)
                    }
                    .padding()
                }
                
                if showingNewPeriod {
                    NewBudgetPeriodView(
                        isPresented: $showingNewPeriod,
                        onSuccess: {
                            showingNewPeriod = false
                            onPeriodCreated()
                        }, isLandingPage: true)
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
    NoCurrentPeriodView(onPeriodCreated: {})
        .environmentObject(BudgetManager())
}
