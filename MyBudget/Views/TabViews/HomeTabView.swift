//
//  HomeTabView.swift
//  MyBudget
//
//  Created by Katya Durneva Svedmark on 2024-12-05.
//

import SwiftUI

struct HomeTabView: View {
    
    @State var showingNewPeriod = false
    
    var budgetfb = BudgetFB()
    
    var body: some View {
        
        ZStack {
            NavigationStack {
                if !showingNewPeriod {
                    VStack {
                        Text("Total Income: \(budgetfb.totalIncome, specifier: "%.2f")")
                            .font(.title)
                            .padding()
                        
                        Text("Total Expense: \(budgetfb.totalExpenses, specifier: "%.2f")")
                            .font(.title)
                        
                        Text("Total Outcome: \(budgetfb.totalIncome - budgetfb.totalExpenses, specifier: "%.2f")")
                            .font(.title)
                            .padding()
                        
                        Button(action: {
                            showingNewPeriod.toggle()
                        }) {
                            ButtonView(buttontext: "Add new period", leadingPadding: 100, trailingPadding: 100)
                        }
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
                if showingNewPeriod {
                    NewBudgetPeriodView(isPresented: $showingNewPeriod)
                        .navigationBarBackButtonHidden(true)
                        .frame(height: 250)
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
    HomeTabView()
}
