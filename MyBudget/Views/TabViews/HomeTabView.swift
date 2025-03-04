//
//  HomeTabView.swift
//  MyBudget
//
//  Created by Katya Durneva Svedmark on 2024-12-05.
//

import SwiftUI

struct HomeTabView: View {
    
    @Binding var showingNewPeriod: Bool
    @State var showingSignOutAlert = false
    
    var budgetfb = BudgetFB()
    @EnvironmentObject var budgetManager: BudgetManager
    @State var showInfo = false
    
    @Environment(\.colorScheme) var colorScheme
    var isDarkMode: Bool {
        return colorScheme == .dark
    }
    
    var body: some View {
        
        ZStack {
            NavigationStack {
                if !showingNewPeriod {
                    VStack (spacing: 15) {
                        
                        PeriodCardView(
                            startDate: budgetManager.currentPeriod.startDate,
                            endDate: budgetManager.currentPeriod.endDate
                        )
                        
                        HStack {
                            StatBoxView(
                                title: String(localized: "Total Income"),
                                amount: budgetfb.totalIncome,
                                isIncome: true,
                                showNegativeAmount: false
                            )
                            
                            StatBoxView(
                                title: String(localized: "Total Expense"),
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
                            Text(String(localized: "Add New Period"))
                                .font(.headline)
                                .foregroundColor(.white)
                                .shadow(radius: 10)
                                .frame(maxWidth: 200)
                                .padding()
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: isDarkMode ? [Color(red: 45/255, green: 50/255, blue: 60/255), Color(red: 32/255, green: 35/255, blue: 42/255)] : [.buttonGradientLight, .buttonGradientDark]),
                                        startPoint: isDarkMode ? .topLeading : .leading,
                                        endPoint: isDarkMode ? .bottomTrailing : .trailing
                                    )
                                )
                                .cornerRadius(16)
                                .shadow(
                                    color: isDarkMode ? Color.black.opacity(0.3) : Color.black.opacity(0.4),
                                    radius: isDarkMode ? 3 : 1,
                                    x: isDarkMode ? 0 : -2,
                                    y: isDarkMode ? 4 : 4
                                )
                                .padding(.top, 15)
                        }
                    }
                    .alert("Are you sure you want to sign out?", isPresented: $showingSignOutAlert) {
                        Button("Go Back", role: .cancel) { }
                        Button("Sign Out", role: .destructive) {
                            budgetfb.userLogout()
                        }
                    }
                    .padding(.horizontal, isDarkMode ? 5 : 15)
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
                        .padding(.horizontal, 16)
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
    HomeTabView(showingNewPeriod: .constant(false))
        .environmentObject(BudgetManager())
}
