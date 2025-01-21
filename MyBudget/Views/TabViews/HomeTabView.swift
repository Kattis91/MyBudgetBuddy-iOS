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
    @EnvironmentObject var budgetManager: BudgetManager
    
    var body: some View {
        
        ZStack {
            NavigationStack {
                if !showingNewPeriod {
                    VStack (spacing: 20) {
                        
                        PeriodCardView(
                            startDate: budgetManager.currentPeriod.startDate,
                            endDate: budgetManager.currentPeriod.endDate
                        )
                        
                        HStack {
                            StatBoxView(
                                title: "Total Income",
                                amount: budgetfb.totalIncome,
                                isIncome: true,
                                showNegativeAmount: false
                            )
                            
                            StatBoxView(
                                title: "Total Expense",
                                amount: budgetfb.totalExpenses,
                                isIncome: false,
                                showNegativeAmount: true
                            )
                        }
                        
                        OutcomeBoxView(
                            income: budgetfb.totalIncome,
                            expenses: budgetfb.totalExpenses
                        )
                        
                        Button(action: {
                            showingNewPeriod.toggle()
                        }) {
                            Text("Add New Period")
                                .font(.headline)
                                .foregroundColor(.white)
                                .shadow(radius: 10)
                                .frame(maxWidth: 150)
                                .padding()
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [.buttonGradientLight, .buttonGradientDark]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(16)
                                .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                        }
                    }
                    .padding()
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
                    NewBudgetPeriodView(isPresented: $showingNewPeriod, isLandingPage: false)
                        .navigationBarBackButtonHidden(true)
                        .frame(height: 500)
                        .background(Color.white)
                        .padding(.horizontal, 24)
                        .cornerRadius(12)
                        .shadow(radius: 10)
                }
            }
        }
        .task {
            // Load data when view appears
            await budgetManager.loadData()
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
    
}

#Preview {
    HomeTabView()
        .environmentObject(BudgetManager())
}
