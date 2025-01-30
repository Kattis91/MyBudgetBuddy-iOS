//
//  HomeTabView.swift
//  MyBudget
//
//  Created by Katya Durneva Svedmark on 2024-12-05.
//

import SwiftUI

struct HomeTabView: View {
    
    @State var showingNewPeriod = false
    @State var showingSignOutAlert = false
    
    var budgetfb = BudgetFB()
    @EnvironmentObject var budgetManager: BudgetManager
    @State var showInfo = false
    
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
                            withAnimation(.spring()) {
                                showingNewPeriod.toggle()
                            }
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
                                .shadow(color: .black.opacity(0.4), radius: 1, x: -2, y: 4)
                                .padding(.top, 15)
                        }
                    }
                    .alert("Are you sure you want to sign out?", isPresented: $showingSignOutAlert) {
                        Button("Go Back", role: .cancel) { }
                        Button("Sign Out", role: .destructive) {
                            budgetfb.userLogout()
                        }
                    }
                    .padding()
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            
                            Button(action: {
                                showingSignOutAlert = true
                            }) {
                                Image(systemName: "escape")
                                    .resizable()
                                    .frame(width: 25, height: 25)
                                    .foregroundStyle(Color(red: 201 / 255, green: 94 / 255, blue: 123 / 255))
                            }
                        }
                        ToolbarItem(placement: .topBarTrailing) {
                            
                            Button(action: {
                                showInfo.toggle()
                            }) {
                                Image(systemName: "info.circle")
                                    .resizable()
                                    .frame(width: 25, height: 25)
                                    .foregroundStyle(Color("CustomGreen"))
                            }
                        }
                    }
                }
                if showingNewPeriod {
                    NewBudgetPeriodView(isPresented: $showingNewPeriod, isLandingPage: false)
                        .navigationBarBackButtonHidden(true)
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
        .sheet(isPresented: $showInfo) {
            InfoPageView()
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
