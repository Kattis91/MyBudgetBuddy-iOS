//
//  HomeView.swift
//  MyBudget
//
//  Created by Katya Durneva Svedmark on 2024-12-01.
//

import SwiftUI
import FirebaseAuth
import Combine
import Firebase

struct HomeView: View {
    
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        
        // Create dynamic background color
        let dynamicBackground = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 28/255, green: 28/255, blue: 30/255, alpha: 1.0)  // Dark mode
                : UIColor(red: 255/255, green: 242/255, blue: 230/255, alpha: 1.0)  // Light mode
        }
        appearance.backgroundColor = dynamicBackground
        
        // Create dynamic colors for unselected items
        let dynamicNormalColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 100/255, green: 105/255, blue: 120/255, alpha: 1.0)  // Darker slate gray
                : UIColor(red: 170/255, green: 170/255, blue: 216/255, alpha: 1.0)  // Light mode
        }
        
        // Create dynamic colors for selected items
        let dynamicSelectedColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark
                ? UIColor.white  // Pure white for maximum visibility
                : UIColor(red: 0/255, green: 51/255, blue: 102/255, alpha: 1.0)  // Light mode
        }
        
        // Apply colors to normal state
        appearance.stackedLayoutAppearance.normal.iconColor = dynamicNormalColor
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: dynamicNormalColor
        ]
        
        // Apply colors to selected state
        appearance.stackedLayoutAppearance.selected.iconColor = dynamicSelectedColor
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: dynamicSelectedColor
        ]
        
        // Apply the appearance settings
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    @EnvironmentObject var budgetManager: BudgetManager
    @State var budgetfb = BudgetFB()
    @State private var hasExistingPeriods = false
    @State private var isCheckingPeriods = true
    @State private var hasCurrentPeriod = false
    @State var showNewPeriodSheet = false
    
    @State private var selectedTab = 0
    @State private var incomeErrorMessage = ""
    @State private var fixedExpenseErrorMessage = ""
    @State private var variableExpenseErrorMessage = ""
    
    @State private var showingNewPeriod = false
    
    // Timer
    @State private var timer: AnyCancellable? = nil
    
    var body: some View {
        
        Group {
            if isCheckingPeriods {
                VStack(spacing: 20) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color("CustomGreen")))
                        .scaleEffect(2.5)
                    
                    Text(String(localized: "Preparing your budget details..."))
                        .font(.headline)
                        .foregroundColor(Color("PrimaryTextColor"))
                        .padding(.top, 10)
                }
            } else {
                if hasExistingPeriods {
                    if hasCurrentPeriod {
                        VStack {
                            TabView(selection: $selectedTab) {
                                HomeTabView(showingNewPeriod: $showingNewPeriod, budgetfb: budgetfb)
                                    .tabItem {
                                        Label("Home", systemImage: "house")
                                    }
                                    .tag(0)
                                
                                IncomesTabView(budgetfb: budgetfb, errorMessage: $incomeErrorMessage)
                                    .tabItem {
                                        Label("Incomes", systemImage: "plus.circle")
                                    }
                                    .tag(1)
                                
                                ExpensesTabView(budgetfb: budgetfb,
                                    fixedErrorMessage: $fixedExpenseErrorMessage,
                                    variableErrorMessage: $variableExpenseErrorMessage)
                                    .tabItem {
                                        Label("Expenses", systemImage: "minus.circle")
                                    }
                                    .tag(2)
                                
                                OverviewTabView()
                                    .tabItem {
                                        Label("Overview", systemImage: "chart.bar")
                                    }
                                    .tag(3)
                            }
                        }
                        .onChange(of: selectedTab) {
                            // Clear error messages directly
                            incomeErrorMessage = ""
                            fixedExpenseErrorMessage = ""
                            variableExpenseErrorMessage = ""
                            showingNewPeriod = false
                        }
                        .onReceive(NotificationCenter.default.publisher(for: .periodUpdated)) { _ in
                            Task {
                                await budgetfb.loadIncomeData()
                                await budgetfb.loadExpenseData(isfixed: true)
                                await budgetfb.loadExpenseData(isfixed: false)
                            }
                        }
                        .accentColor(Color("PrimaryTextColor"))
                    } else {
                        NoCurrentPeriodView(onPeriodCreated: {
                            hasCurrentPeriod = true
                            loadInitialData()
                        }, isFirstTime: false)
                    }
                } else {
                    NoCurrentPeriodView(onPeriodCreated: {
                        hasExistingPeriods = true
                        hasCurrentPeriod = true
                        loadInitialData()
                    }, isFirstTime: true)
                }
            }
        }
        .onAppear {
            checkInitialState()
            startTimer()
        }
        .onDisappear {
            timer?.cancel()
        }
    }
    
    private func checkInitialState() {
        isCheckingPeriods = true
        
        // First check if any periods exist (current or historical)
        budgetfb.checkForAnyBudgetPeriod { exists in
            hasExistingPeriods = exists
            
            if exists {
                // Then check if there's a current period
                budgetfb.loadCurrentBudgetPeriod { loadedPeriod in
                    hasCurrentPeriod = loadedPeriod != nil
                    
                    if loadedPeriod != nil {
                        loadInitialData()
                    }
                    
                    isCheckingPeriods = false
                }
            } else {
                isCheckingPeriods = false
            }
        }
    }
    
    private func loadInitialData() {
        budgetfb.loadCurrentBudgetPeriod { loadedPeriod in
            if let loadedPeriod = loadedPeriod {
                DispatchQueue.main.async {
                    budgetManager.currentPeriod = loadedPeriod
                }
            }
        }
        
        Task {
            await budgetfb.loadIncomeData()
            await budgetfb.loadExpenseData(isfixed: true)
            await budgetfb.loadExpenseData(isfixed: false)
            await budgetManager.loadData()
        }
    }
    
    private func startTimer() {
        // Cancel any existing timer first
        timer?.cancel()
        
        let calendar = Calendar.current
        let midnight = calendar.startOfDay(for: Date().addingTimeInterval(86400))
        let timeUntilMidnight = midnight.timeIntervalSinceNow
        
        timer = Timer.publish(every: timeUntilMidnight, on: .main, in: .default)
            .autoconnect()
            .sink { _ in
                checkPeriodExpiration()
                // Schedule the next day's timer after a short delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    startTimer()
                }
            }
    }
    
    private func checkPeriodExpiration() {
        budgetfb.loadCurrentBudgetPeriod { loadedPeriod in
            if let loadedPeriod = loadedPeriod, loadedPeriod.endDate < Date() {
                DispatchQueue.main.async {
                    hasCurrentPeriod = false
                    // Trigger UI update via your existing notification mechanism
                    NotificationCenter.default.post(name: .periodUpdated, object: nil)
                }
            }
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(BudgetManager())
}
