//
//  BudgetFB.swift
//  MyBudget
//
//  Created by Katya Durneva Svedmark on 2024-12-01.
//

import Foundation
import Firebase
import FirebaseAuth

@Observable class BudgetFB {
    
    var loginerror : String?
    var historicalPeriods: [BudgetPeriod] = []
    
    var totalIncome: Double = 0.0
    var incomeList: [Income] = []
    var totalExpenses: Double = 0.0
    var fixedExpenseList: [Expense] = []
    var variableExpenseList: [Expense] = []
    var groupedIncome: [String: Double] = [:]
    var groupedExpense: [String: Double] = [:]
    
    
    func userLogin(email : String, password : String, completion: @escaping (String?) -> Void) {
        Task {
            do {
                try await Auth.auth().signIn(withEmail: email, password: password)
                print("Successfully logged in")
                completion(nil)
            } catch {
                print("Login failed: \(error.localizedDescription)")
                completion(error.localizedDescription) // Return Firebase error
            }
        }
    }
    
    func userRegister(email: String, password: String, completion: @escaping (String?) -> Void) {
        Task {
            do {
                let regResult = try await Auth.auth().createUser(withEmail: email, password: password)
                print("Registration successful for user: \(regResult.user.email ?? "Unknown")")
                completion(nil)
            } catch {
                print("Registration failed: \(error.localizedDescription)")
                completion(error.localizedDescription)
            }
        }
    }

    func createCleanBudgetPeriod(startDate: Date, endDate: Date, completion: @escaping (Bool) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(false)
            return
        }
        
        let newBudgetPeriod = BudgetPeriod(
            startDate: startDate,
            endDate: endDate,
            incomes: [],
            fixedExpenses: [],
            variableExpenses: []
        )
 
        let ref = Database.database().reference()
        let budgetId = UUID().uuidString
        let newBudgetRef = ref.child("budgetPeriods").child(userId).child(budgetId)
        
        // We're manually saving the period to ensure no data transfer happens
        let periodData = newBudgetPeriod.toDictionary()
        newBudgetRef.setValue(periodData) { error, _ in
            if let error = error {
                print("Error creating clean budget period: \(error.localizedDescription)")
                completion(false)
            } else {
                print("Clean budget period created successfully")
                completion(true)
            }
        }
    }
    
    func userLogout() {
        do {
            try Auth.auth().signOut()
        } catch {
            
        }
    }
    
    func forgotPassword(email : String, completion: @escaping (String?) -> Void) {
        Task {
            do {
                try await Auth.auth().sendPasswordReset(withEmail: email)
                print("Sent!")
                completion(nil)
            } catch {
                print("Reset failed: \(error.localizedDescription)")
                completion(error.localizedDescription)
            }
        }
    }
    
    
    func saveIncomeData(amount: Double, category: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let ref = Database.database().reference()
        
        // First get current budget period
        loadCurrentBudgetPeriod { [weak self] budgetPeriod in
            guard let budgetPeriod = budgetPeriod else { return }
            
            // Reference to the incomes array in the current budget period
            let incomesRef = ref.child("budgetPeriods")
                .child(userId)
                .child(budgetPeriod.id)
                .child("incomes")
            
            // First fetch all existing incomes
            incomesRef.observeSingleEvent(of: .value) { [weak self] snapshot in
                var incomes: [[String: Any]] = []
                
                // Convert existing incomes to array if they exist
                if let existingIncomes = snapshot.value as? [[String: Any]] {
                    incomes = existingIncomes
                }
                
                // Check if we already have an income with this category
                if let existingIndex = incomes.firstIndex(where: { ($0["category"] as? String) == category }) {
                    // Update existing category amount
                    let existingAmount = incomes[existingIndex]["amount"] as? Double ?? 0
                    incomes[existingIndex]["amount"] = existingAmount + amount
                } else {
                    // Add new income entry
                    let newIncome: [String: Any] = [
                        "id": UUID().uuidString,
                        "amount": amount,
                        "category": category
                    ]
                    incomes.append(newIncome)
                }
                
                // Save the updated incomes array
                incomesRef.setValue(incomes) { error, _ in
                    if error == nil {
                        
                        // Calculate new total
                        let newTotal = incomes.reduce(0) { $0 + ($1["amount"] as? Double ?? 0) }
                        
                        // Update the total in Firebase
                        ref.child("budgetPeriods")
                           .child(userId)
                           .child(budgetPeriod.id)
                           .child("totalIncome")
                           .setValue(newTotal)
                        
                        Task { @MainActor in
                            await self?.loadIncomeData()
                        }
                    }
                }
            }
        }
    }
    
    
    func loadIncomeData() async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let ref = Database.database().reference()
        
        // Get current budget period first
        return await withCheckedContinuation { continuation in
            loadCurrentBudgetPeriod { budgetPeriod in
                guard let budgetPeriod = budgetPeriod else {
                    continuation.resume()
                    return
                }
                
                // Load incomes for current period
                ref.child("budgetPeriods").child(userId)
                    .child(budgetPeriod.id).child("incomes")
                    .getData { [weak self] error, snapshot in
                        if let snapshot = snapshot {
                            Task { @MainActor in
                                let processedData = await self?.processIncomeData(snapshot)
                                self?.incomeList = processedData?.incomes ?? []
                                self?.groupedIncome = processedData?.grouped ?? [:]
                                self?.totalIncome = processedData?.total ?? 0
                            }
                        }
                        continuation.resume()
                    }
            }
        }
    }
    
    // Helper function to process income data
    func processIncomeData(_ snapshot: DataSnapshot) async -> (incomes: [Income], grouped: [String: Double], total: Double) {
        var incomeList: [Income] = []
        var groupedIncome: [String: Double] = [:]
        var totalIncome: Double = 0.0
        
        // Processing remains same - snapshot now points to period's incomes node
        for incomeitem in snapshot.children {
            guard let incomesnap = incomeitem as? DataSnapshot,
                  let incomeDataDict = incomesnap.value as? [String: Any] else {
                continue
            }
            
            let fetchedIncome = Income(
                id: incomesnap.key,
                amount: incomeDataDict["amount"] as? Double ?? 0.0,
                category: incomeDataDict["category"] as? String ?? "Unknown"
            )
            
            incomeList.append(fetchedIncome)
            
            let category = fetchedIncome.category
            groupedIncome[category] = (groupedIncome[category] ?? 0.0) + fetchedIncome.amount
        }
        
        totalIncome = incomeList.reduce(0.0) { $0 + $1.amount }
        
        return (incomeList, groupedIncome, totalIncome)
    }
    
    func deleteIncome(at offsets: IndexSet) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let ref = Database.database().reference()
        
        loadCurrentBudgetPeriod { [weak self] budgetPeriod in
            guard let budgetPeriod = budgetPeriod,
                  let self = self else { return }
            
            // Create a mutable copy of the income list
            var updatedIncomeList = self.incomeList
            // Remove the items at the specified offsets
            updatedIncomeList.remove(atOffsets: offsets)
            
            // Convert to Firebase format - array of dictionaries
            let incomesToSave: [[String: Any]] = updatedIncomeList.map { income in
                return [
                    "id": income.id,
                    "amount": income.amount,
                    "category": income.category
                ]
            }
            
            // Update the entire incomes array in Firebase
            ref.child("budgetPeriods")
                .child(userId)
                .child(budgetPeriod.id)
                .child("incomes")
                .setValue(incomesToSave) { error, _ in
                    if error == nil {
                        // Update local data only after successful Firebase update
                        self.incomeList.remove(atOffsets: offsets)
                        
                        // Calculate and update the total
                        let newTotal = updatedIncomeList.reduce(0.0) { $0 + $1.amount }
                        self.totalIncome = newTotal
                        
                        // Update the total in Firebase
                        ref.child("budgetPeriods")
                           .child(userId)
                           .child(budgetPeriod.id)
                           .child("totalIncome")
                           .setValue(newTotal)
                    }
                }
        }
    }
    
    /*
     func saveExpenseData(amount: Double, category: String, isfixed: Bool) {
     guard let userId = Auth.auth().currentUser?.uid else { return }
     let ref = Database.database().reference()
     
     // First get current budget period
     loadCurrentBudgetPeriod { [weak self] budgetPeriod in
     guard let budgetPeriod = budgetPeriod else { return }
     
     // Create expense under current budget period
     let expenseRef = ref.child("budgetPeriods").child(userId)
     .child(budgetPeriod.id).child("expenses")
     .childByAutoId()
     
     expenseRef.setValue([
     "amount": amount,
     "category": category,
     "isfixed": isfixed
     ]) { error, _ in
     if error == nil {
     Task { @MainActor in
     await self?.loadExpenseData()
     }
     }
     }
     }
     }
     */
    /*
     func saveExpenseData(amount: Double, category: String, isfixed: Bool) {
     guard let userId = Auth.auth().currentUser?.uid else { return }
     let ref = Database.database().reference()
     
     // First get current budget period
     loadCurrentBudgetPeriod { [weak self] budgetPeriod in
     guard let budgetPeriod = budgetPeriod else { return }
     
     // Reference to the category in the current budget period
     let categoryRef = ref.child("budgetPeriods")
     .child(userId)
     .child(budgetPeriod.id)
     .child(isfixed ? "fixedExpenses" : "variableExpenses")
     .child(category)
     
     // Check if the category already exists
     categoryRef.observeSingleEvent(of: .value) { [weak self] snapshot in
     guard let self = self else { return } // Säkerställ att self fortfarande existerar
     if snapshot.exists(),
     let existingData = snapshot.value as? [String: Any],
     let existingAmount = existingData["amount"] as? Double {
     // Kategori finns, uppdatera summan
     let updatedAmount = existingAmount + amount
     categoryRef.setValue(["amount": updatedAmount, "category": category, "isfixed": isfixed]) { error, _ in
     if error == nil {
     Task { @MainActor in
     await self.loadExpenseData(isfixed: isfixed)
     }
     }
     }
     } else {
     // Kategori finns inte, skapa en ny
     categoryRef.setValue(["amount": amount, "category": category, "isfixed": isfixed]) { error, _ in
     if error == nil {
     Task { @MainActor in
     await self.loadExpenseData(isfixed: isfixed)
     }
     }
     }
     }
     }
     
     }
     }
     */
    
    func saveExpenseData(amount: Double, category: String, isfixed: Bool) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let ref = Database.database().reference()
        
        // First get current budget period
        loadCurrentBudgetPeriod { [weak self] budgetPeriod in
            guard let budgetPeriod = budgetPeriod else { return }
            
            // Reference to the incomes array in the current budget period
            let expensesRef = ref.child("budgetPeriods")
                .child(userId)
                .child(budgetPeriod.id)
                .child(isfixed ? "fixedExpenses" : "variableExpenses")
            
            // First fetch all existing expenses
            expensesRef.observeSingleEvent(of: .value) { [weak self] snapshot in
                var expenses: [[String: Any]] = []
                
                // Convert existing incomes to array if they exist
                if let existingExpenses = snapshot.value as? [[String: Any]] {
                    expenses = existingExpenses
                }
                
                // Check if we already have an income with this category
                if let existingIndex = expenses.firstIndex(where: { ($0["category"] as? String) == category }) {
                    // Update existing category amount
                    let existingAmount = expenses[existingIndex]["amount"] as? Double ?? 0
                    expenses[existingIndex]["amount"] = existingAmount + amount
                } else {
                    // Add new income entry
                    let newExpense: [String: Any] = [
                        "id": UUID().uuidString,
                        "amount": amount,
                        "category": category,
                        "isfixed": isfixed
                    ]
                    expenses.append(newExpense)
                }
                
                // Save the updated incomes array
                expensesRef.setValue(expenses) { error, _ in
                    if error == nil {
                        
                        // Calculate new total
                        let newTotal = expenses.reduce(0) { $0 + ($1["amount"] as? Double ?? 0) }
                        
                        // Update the total in Firebase
                        ref.child("budgetPeriods")
                           .child(userId)
                           .child(budgetPeriod.id)
                           .child(isfixed ? "totalFixedExpenses" : "totalVariableExpenses")
                           .setValue(newTotal)
                        
                        Task { @MainActor in
                            await self?.loadExpenseData(isfixed: true)
                            await self?.loadExpenseData(isfixed: false)
                        }
                    }
                }
            }
        }
    }
    
    func loadExpenseData(isfixed: Bool) async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let ref = Database.database().reference()
        
        return await withCheckedContinuation { continuation in
            loadCurrentBudgetPeriod { [weak self] budgetPeriod in
                guard let self = self,
                      let budgetPeriod = budgetPeriod else {
                    continuation.resume()
                    return
                }
                
                ref.child("budgetPeriods").child(userId)
                    .child(budgetPeriod.id)
                    .child(isfixed ? "fixedExpenses" : "variableExpenses")
                    .getData { error, snapshot in
                        guard let snapshot = snapshot else {
                            continuation.resume()
                            return
                        }
                        
                        Task { @MainActor in
                            let processedData = await self.processExpenseData(snapshot)
                            
                            // Update only the relevant list based on isfixed
                            if isfixed {
                                self.fixedExpenseList = processedData.fixedExpenses
                            } else {
                                self.variableExpenseList = processedData.variableExpenses
                            }
                            
                            self.groupedExpense = processedData.grouped
                            
                            // Calculate total from both lists
                            self.totalExpenses = (self.fixedExpenseList.reduce(0) { $0 + $1.amount }) +
                            (self.variableExpenseList.reduce(0) { $0 + $1.amount })
                            
                            continuation.resume()
                        }
                    }
            }
        }
    }
    
    // Helper function to process expense data
    func processExpenseData(_ snapshot: DataSnapshot) async -> (fixedExpenses: [Expense], variableExpenses: [Expense], grouped: [String: Double], total: Double) {
        var fixedExpenseList: [Expense] = []
        var variableExpenseList: [Expense] = []
        var groupedExpense: [String: Double] = [:]
        var totalExpenses: Double = 0.0
        
        for expenseitem in snapshot.children {
            guard let expensesnap = expenseitem as? DataSnapshot,
                  let expenseDataDict = expensesnap.value as? [String: Any] else {
                continue
            }
            
            let fetchedExpense = Expense(
                id: expensesnap.key,
                amount: expenseDataDict["amount"] as? Double ?? 0.0,  // Default to 0.0 if not found
                category: expenseDataDict["category"] as? String ?? "Unknown",
                isfixed: expenseDataDict["isfixed"] as? Bool ?? false  // Default to "Unknown" if not found
            )
            
            if fetchedExpense.isfixed {
                fixedExpenseList.append(fetchedExpense)
            } else {
                variableExpenseList.append(fetchedExpense)
            }
            
            // Group and sum by category
            let category = fetchedExpense.category
            groupedExpense[category] = (groupedExpense[category] ?? 0.0) + fetchedExpense.amount
        }
        
        // Calculate new total
        totalExpenses = fixedExpenseList.reduce(0.0) { $0 + $1.amount } + variableExpenseList.reduce(0.0) { $0 + $1.amount }
        
        return (fixedExpenseList, variableExpenseList, groupedExpense, totalExpenses)
    }
    
    
    func deleteExpense(isfixed: Bool, from listType: String, at offsets: IndexSet) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let ref = Database.database().reference()
        
        loadCurrentBudgetPeriod { [weak self] budgetPeriod in
            guard let budgetPeriod = budgetPeriod,
                  let self = self else { return }
            
            // Determine which list to use based on `listType`
            var expenseList: [Expense]
            switch listType {
            case "fixed":
                expenseList = self.fixedExpenseList
            case "variable":
                expenseList = self.variableExpenseList
            default:
                print("Invalid list type")
                return
            }
            
            // Create a mutable copy of the expense list
            var updatedExpenseList = expenseList
            // Remove the items at the specified offsets
            updatedExpenseList.remove(atOffsets: offsets)
            
            // Convert to Firebase format - array of dictionaries
            let expensesToSave: [[String: Any]] = updatedExpenseList.map { expense in
                return [
                    "id": expense.id,
                    "amount": expense.amount,
                    "category": expense.category,
                    "isfixed": expense.isfixed
                ]
            }
            
            // Update the entire expenses array in Firebase
            let expenseType = isfixed ? "fixedExpenses" : "variableExpenses"
            ref.child("budgetPeriods")
                .child(userId)
                .child(budgetPeriod.id)
                .child(expenseType)
                .setValue(expensesToSave) { error, _ in
                    if error == nil {
                        // Update local data only after successful Firebase update
                        if listType == "fixed" {
                            self.fixedExpenseList.remove(atOffsets: offsets)
                        } else if listType == "variable" {
                            self.variableExpenseList.remove(atOffsets: offsets)
                        }
                        
                        // Recalculate total expenses
                        self.totalExpenses = (self.fixedExpenseList + self.variableExpenseList)
                            .reduce(0.0) { $0 + $1.amount }
                        
                        // Update the total in Firebase
                        ref.child("budgetPeriods")
                            .child(userId)
                            .child(budgetPeriod.id)
                            .child("totalExpenses")
                            .setValue(self.totalExpenses)
                    }
                }
        }
    }
    
    func saveBudgetPeriod(_ budgetPeriod: BudgetPeriod) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let ref = Database.database().reference()
        let budgetRef = ref.child("budgetPeriods").child(userId).child(budgetPeriod.id)
        
        budgetRef.setValue(budgetPeriod.toDictionary()) { error, _ in
            if let error = error {
                print("Failed to save budget period: \(error.localizedDescription)")
            } else {
                print("Successfully saved budget period")
            }
        }
    }
    
    func saveBudgetPeriod(_ budgetPeriod: BudgetPeriod, transferData: (incomes: Bool, expenses: Bool), isfixed: Bool, completion: @escaping (Bool) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(false)
            return
        }
        
        let ref = Database.database().reference()
        let newBudgetRef = ref.child("budgetPeriods").child(userId).child(budgetPeriod.id)
        
        // First, get and save the current period as historical
        loadCurrentBudgetPeriod { [weak self] currentPeriod in
            if let currentPeriod = currentPeriod {
                // Always save the current period as historical, even if it's empty
                self?.saveHistoricalPeriods(currentPeriod)
            }
            
            // Now proceed with saving the new period
            newBudgetRef.setValue(budgetPeriod.toDictionary()) { error, _ in
                guard error == nil else {
                    completion(false)
                    return
                }
                
                // If we're not transferring any data or if both lists are empty, complete here
                if !transferData.incomes && !transferData.expenses {
                    completion(true)
                    return
                }
                
                self?.loadCurrentBudgetPeriod { currentPeriod in
                    guard let currentId = currentPeriod?.id else {
                        completion(true)
                        return
                    }
                    
                    let currentRef = ref.child("budgetPeriods").child(userId).child(currentId)
                    let group = DispatchGroup()
                    
                    // Rest of your existing transfer logic remains the same...
                    if transferData.incomes {
                        group.enter()
                        currentRef.child("incomes").getData { error, snapshot in
                            if let value = snapshot?.value {
                                newBudgetRef.child("incomes").setValue(value) { _, _ in
                                    group.leave()
                                }
                            } else {
                                group.leave()
                            }
                        }
                    }
                    
                    if transferData.expenses {
                        group.enter()
                        currentRef.child(isfixed ? "fixedExpenses" : "variableExpenses").getData { error, snapshot in
                            if let value = snapshot?.value {
                                newBudgetRef.child(isfixed ? "fixedExpenses" : "variableExpenses").setValue(value) { _, _ in
                                    group.leave()
                                }
                            } else {
                                group.leave()
                            }
                        }
                    }
                    
                    group.notify(queue: .main) {
                        completion(true)
                    }
                }
            }
        }
    }
    
    func loadCurrentBudgetPeriod(completion: @escaping (BudgetPeriod?) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("Failed to load budget period: No user ID")
            completion(nil)
            return
        }
        
        let ref = Database.database().reference()
        let budgetPeriodsRef = ref.child("budgetPeriods").child(userId)
        
        budgetPeriodsRef.queryOrdered(byChild: "startDate")
            .queryLimited(toLast: 1)
            .observeSingleEvent(of: .value) { snapshot in
                guard snapshot.exists(),
                      let periodData = snapshot.children.allObjects.first as? DataSnapshot,
                      let dict = periodData.value as? [String: Any],
                      var budgetPeriod = BudgetPeriod(dict: dict) else {
                    completion(nil)
                    return
                }
                
                // Check if period has expired
                let calendar = Calendar.current
                let today = calendar.startOfDay(for: Date())
                let periodEndDate = calendar.startOfDay(for: budgetPeriod.endDate)
                
                if periodEndDate < today {
                    budgetPeriod.id = periodData.key
                    self.saveHistoricalPeriods(budgetPeriod) { success in
                        if success {
                            periodData.ref.removeValue { error, _ in
                                if let error = error {
                                    print("Error removing expired period: \(error.localizedDescription)")
                                }
                                completion(nil)
                            }
                        } else {
                            completion(nil)
                        }
                    }
                    return
                }
                            
                // Set the ID from the snapshot key
                budgetPeriod.id = periodData.key
                completion(budgetPeriod)
            }
    }
    
    func checkForAnyBudgetPeriod(completion: @escaping (Bool) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(false)
            return
        }
        
        let ref = Database.database().reference()
        let budgetPeriodsRef = ref.child("budgetPeriods").child(userId)
        let historicalPeriodsRef = ref.child("historicalPeriods").child(userId)
        
        // Check both current and historical periods
        let group = DispatchGroup()
        var hasCurrentPeriods = false
        var hasHistoricalPeriods = false
        
        group.enter()
        budgetPeriodsRef.observeSingleEvent(of: .value) { snapshot in
            hasCurrentPeriods = snapshot.exists() && snapshot.hasChildren()
            group.leave()
        }
        
        group.enter()
        historicalPeriodsRef.observeSingleEvent(of: .value) { snapshot in
            hasHistoricalPeriods = snapshot.exists() && snapshot.hasChildren()
            group.leave()
        }
        
        group.notify(queue: .main) {
            completion(hasCurrentPeriods || hasHistoricalPeriods)
        }
    }
    
    func saveHistoricalPeriods(_ budgetPeriod: BudgetPeriod, completion: @escaping (Bool) -> Void = { _ in }) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let ref = Database.database().reference()
        
        // If the period is empty, just remove it from budgetPeriods without saving to historical
        if budgetPeriod.incomes.isEmpty &&
           budgetPeriod.fixedExpenses.isEmpty &&
           budgetPeriod.variableExpenses.isEmpty {
            let currentPeriodRef = ref.child("budgetPeriods").child(userId).child(budgetPeriod.id)
            currentPeriodRef.removeValue { error, _ in
                if let error = error {
                    print("Error removing empty period: \(error.localizedDescription)")
                    completion(false)
                } else {
                    print("Successfully removed empty period")
                    completion(true)
                }
            }
            return
        }
        
        // Generate a new unique ID for this historical period
        let periodRef = ref.child("historicalPeriods").child(userId).child(budgetPeriod.id)
        
        periodRef.observeSingleEvent(of: .value) { snapshot in
            guard !snapshot.exists() else {
                print("Period already exists in historical periods: \(budgetPeriod.id)")
                completion(true)
                return
            }
            
            // Save the complete income and expense data, not just IDs
            let periodData: [String: Any] = [
                "startDate": budgetPeriod.startDate.timeIntervalSince1970,
                "endDate": budgetPeriod.endDate.timeIntervalSince1970,
                "becameHistoricalDate": budgetPeriod.becameHistoricalDate.timeIntervalSince1970, // Add this line
                "expired": true,
                "incomes": budgetPeriod.incomes.map { [
                    "id": $0.id,
                    "amount": $0.amount,
                    "category": $0.category
                ] },
                "fixedExpenses": budgetPeriod.fixedExpenses.map { [
                    "id": $0.id,
                    "amount": $0.amount,
                    "category": $0.category,
                    "isfixed": $0.isfixed
                ] },
                "variableExpenses": budgetPeriod.variableExpenses.map { [
                    "id": $0.id,
                    "amount": $0.amount,
                    "category": $0.category,
                    "isfixed": $0.isfixed
                ] }
            ]
            
            // Save to historical periods
            periodRef.setValue(periodData) { error, _ in
                if let error = error {
                    print("Error saving to historical periods: \(error.localizedDescription)")
                    completion(false)
                } else {
                    // After successful save to historical, remove from current periods
                    let currentPeriodRef = ref.child("budgetPeriods").child(userId).child(budgetPeriod.id)
                    currentPeriodRef.removeValue { error, _ in
                        if let error = error {
                            print("Error removing from current periods: \(error.localizedDescription)")
                        } else {
                            print("Successfully moved period to historical and removed from current")
                        }
                        completion(true)
                    }
                }
            }
        }
    }

    func loadHistoricalPeriods() async -> [BudgetPeriod] {
        guard let userId = Auth.auth().currentUser?.uid else { return [] }
        let ref = Database.database().reference()
        
        return await withCheckedContinuation { continuation in
            ref.child("historicalPeriods").child(userId)
                .getData { [weak self] error, snapshot in
                    if let error {
                        print("Error fetching historical periods: \(error)")
                        continuation.resume(returning: [])
                        return
                    }
                    
                    guard let snapshot = snapshot else {
                        continuation.resume(returning: [])
                        return
                    }
                    
                    Task {
                        let processedData = await self?.processHistoricalData(snapshot) ?? []
                        continuation.resume(returning: processedData)
                    }
                }
        }
    }

    func processHistoricalData(_ snapshot: DataSnapshot) async -> [BudgetPeriod] {
        var periods: [BudgetPeriod] = []
        
        for historicalItem in snapshot.children {
            guard let historicalSnap = historicalItem as? DataSnapshot,
                  let historicalDataDict = historicalSnap.value as? [String: Any] else {
                continue
            }
            
            // Get the start and end dates
            let startDate = Date(timeIntervalSince1970: historicalDataDict["startDate"] as? TimeInterval ?? 0)
            let endDate = Date(timeIntervalSince1970: historicalDataDict["endDate"] as? TimeInterval ?? 0)
            
            let becameHistoricalDate: Date
                if let timestamp = historicalDataDict["becameHistoricalDate"] as? TimeInterval {
                    becameHistoricalDate = Date(timeIntervalSince1970: timestamp)
                } else {
                    // If not found, use the older of startDate or current date as fallback
                    becameHistoricalDate = min(startDate, Date())
                }
            
            // Process incomes with complete data
            let incomes = (historicalDataDict["incomes"] as? [[String: Any]])?.compactMap { incomeData -> Income? in
                guard let id = incomeData["id"] as? String,
                      let category = incomeData["category"] as? String else {
                    return nil
                }
                
                // Handle different types of amount data
                let amount: Double
                if let numberAmount = incomeData["amount"] as? Double {
                    amount = numberAmount
                } else if let stringAmount = incomeData["amount"] as? String,
                          let parsedAmount = Double(stringAmount) {
                    amount = parsedAmount
                } else if let intAmount = incomeData["amount"] as? Int {
                    amount = Double(intAmount)
                } else {
                    return nil
                }
                
                return Income(id: id, amount: amount, category: category)
            } ?? []
            
            // Process fixed expenses with complete data
            let fixedExpenses = (historicalDataDict["fixedExpenses"] as? [[String: Any]])?.compactMap { expenseData -> Expense? in
                guard let id = expenseData["id"] as? String,
                      let category = expenseData["category"] as? String else {
                    return nil
                }
                
                // Handle different types of amount data
                let amount: Double
                if let numberAmount = expenseData["amount"] as? Double {
                    amount = numberAmount
                } else if let stringAmount = expenseData["amount"] as? String,
                          let parsedAmount = Double(stringAmount) {
                    amount = parsedAmount
                } else if let intAmount = expenseData["amount"] as? Int {
                    amount = Double(intAmount)
                } else {
                    return nil
                }
                
                return Expense(id: id, amount: amount, category: category, isfixed: true)
            } ?? []
            
            // Process variable expenses with complete data
            let variableExpenses = (historicalDataDict["variableExpenses"] as? [[String: Any]])?.compactMap { expenseData -> Expense? in
                guard let id = expenseData["id"] as? String,
                      let category = expenseData["category"] as? String else {
                    return nil
                }
                
                // Handle different types of amount data
                let amount: Double
                if let numberAmount = expenseData["amount"] as? Double {
                    amount = numberAmount
                } else if let stringAmount = expenseData["amount"] as? String,
                          let parsedAmount = Double(stringAmount) {
                    amount = parsedAmount
                } else if let intAmount = expenseData["amount"] as? Int {
                    amount = Double(intAmount)
                } else {
                    return nil
                }
                
                return Expense(id: id, amount: amount, category: category, isfixed: false)
            } ?? []
            
            // Create the period with all the data
            let period = BudgetPeriod(
                startDate: startDate,
                endDate: endDate,
                incomes: incomes,
                fixedExpenses: fixedExpenses,
                variableExpenses: variableExpenses,
                becameHistoricalDate: becameHistoricalDate
            )
            
            periods.append(period)
        }
        
        return periods.sorted { $0.becameHistoricalDate < $1.becameHistoricalDate }
    }
    
    func deleteHistoricalPeriod(at offsets: IndexSet, from periods: [BudgetPeriod]) async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let ref = Database.database().reference()
        
        // Since the UI shows periods in reverse order, we need to adjust the indices
        let reversedPeriods = Array(periods.reversed())
        let periodsToDelete = offsets.map { reversedPeriods[$0] }
        
        do {
            // Get a snapshot of all historical periods
            let snapshot = try await ref.child("historicalPeriods").child(userId).getData()
            
            guard let snapshot = snapshot.value as? [String: [String: Any]] else { return }
            
            // Find and delete matching periods
            for (key, periodData) in snapshot {
                guard let startDate = periodData["startDate"] as? TimeInterval,
                      let endDate = periodData["endDate"] as? TimeInterval else {
                    continue
                }
                
                // Check if this period matches any of our periods to delete
                for periodToDelete in periodsToDelete {
                    if startDate == periodToDelete.startDate.timeIntervalSince1970 &&
                       endDate == periodToDelete.endDate.timeIntervalSince1970 {
                        // Delete from Firebase
                        try await ref.child("historicalPeriods").child(userId).child(key).removeValue()
                        print("Successfully deleted period with key: \(key)")
                    }
                }
            }
            
            // Reload the historical periods to update the UI
            let updatedPeriods = await loadHistoricalPeriods()
            
            await MainActor.run {
                NotificationCenter.default.post(
                    name: .init("HistoricalPeriodsUpdated"),
                    object: updatedPeriods
                )
            }
        } catch {
            print("Error deleting period: \(error.localizedDescription)")
        }
    }
    
    // Add category management functions
    func loadCategories(type: CategoryType) async -> [String] {
        guard let userId = Auth.auth().currentUser?.uid else { return [] }
        
        return await withCheckedContinuation { continuation in
            let ref = Database.database().reference()
                .child("categories")
                .child(userId)
                .child(type.rawValue)
            
            ref.observeSingleEvent(of: .value) { snapshot in
                if let categories = snapshot.value as? [String] {
                    continuation.resume(returning: categories)
                } else {
                    // If no categories exist, create default ones
                    let defaults = type.defaultCategories
                    ref.setValue(defaults) { error, _ in
                        continuation.resume(returning: defaults)
                    }
                }
            }
        }
    }
    
    func addCategory(name: String, type: CategoryType) async -> Bool {
        guard let userId = Auth.auth().currentUser?.uid else { return false }
        
        return await withCheckedContinuation { continuation in
            let ref = Database.database().reference()
                .child("categories")
                .child(userId)
                .child(type.rawValue)
            
            ref.observeSingleEvent(of: .value) { snapshot in
                var categories = snapshot.value as? [String] ?? []
                
                guard !categories.contains(name) else {
                    continuation.resume(returning: false)
                    return
                }
                
                categories.append(name)
                ref.setValue(categories) { error, _ in
                    continuation.resume(returning: error == nil)
                }
            }
        }
    }
    
    func editCategory(oldName: String, newName: String, type: CategoryType) async -> Bool {
       guard let userId = Auth.auth().currentUser?.uid else { return false }
       
       return await withCheckedContinuation { continuation in
           let ref = Database.database().reference()
               .child("categories")
               .child(userId)
               .child(type.rawValue)
           
           ref.observeSingleEvent(of: .value) { snapshot in
               var categories = snapshot.value as? [String] ?? []
               
               guard let index = categories.firstIndex(of: oldName) else {
                   continuation.resume(returning: false)
                   return
               }
               
               categories[index] = newName
               
               ref.setValue(categories) { error, _ in
                   continuation.resume(returning: error == nil)
               }
           }
       }
    }
    
    // Delete category
   func deleteCategory(name: String, type: CategoryType) async -> Bool {
       guard let userId = Auth.auth().currentUser?.uid else { return false }
       
       return await withCheckedContinuation { continuation in
           let ref = Database.database().reference()
               .child("categories")
               .child(userId)
               .child(type.rawValue)
           
           ref.observeSingleEvent(of: .value) { snapshot in
               var categories = snapshot.value as? [String] ?? []
               categories.removeAll { $0 == name }
               
               ref.setValue(categories) { error, _ in
                   continuation.resume(returning: error == nil)
               }
           }
       }
   }
    
    func saveInvoiceReminder(title: String, amount: Double, expiryDate: Date) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("Error: Unable to retrieve user ID")
            return
        }
        var ref: DatabaseReference!
        
        ref = Database.database().reference()
        
        let invoiceEntry: [String: Any] = [
            "title": title,
            "amount": amount,
            "expiryDate": expiryDate.timeIntervalSince1970,
            "processed": false,
            "uid": userId // Including userId in the data for further verification
        ]
        
        ref.child("invoices").child(userId).childByAutoId().setValue(invoiceEntry) { error, _ in
            if let error = error {
                print("Error saving invoice: \(error.localizedDescription)")
            } else {
                print("Invoice saved successfully")
            }
        }
    }
    
    func updateInvoiceStatus(invoiceId: String, processed: Bool) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "InvoiceError", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }
        
        let ref = Database.database().reference()
            .child("invoices")
            .child(userId)
            .child(invoiceId)
        
        return try await withCheckedThrowingContinuation { continuation in
            ref.updateChildValues(["processed": processed]) { error, _ in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }
    
    func loadInvoicesByStatus(processed: Bool) async -> [Invoice] {
        guard let userId = Auth.auth().currentUser?.uid else { return [] }
        
        return await withCheckedContinuation { continuation in
            let ref = Database.database().reference().child("invoices").child(userId)
            
            // Query to filter by processed status
            ref.queryOrdered(byChild: "processed")
               .queryEqual(toValue: processed)
               .observeSingleEvent(of: .value) { snapshot in
                var invoices: [Invoice] = []
                
                for child in snapshot.children {
                    if let childSnapshot = child as? DataSnapshot,
                       let invoiceData = childSnapshot.value as? [String: Any],
                       let title = invoiceData["title"] as? String,
                       let amount = invoiceData["amount"] as? Double,
                       let processed = invoiceData["processed"] as? Bool,
                       let expiryDateTimestamp = invoiceData["expiryDate"] as? TimeInterval {
                        let expiryDate = Date(timeIntervalSince1970: expiryDateTimestamp)
                        let invoice = Invoice(id: childSnapshot.key, title: title, amount: amount, processed: processed, expiryDate: expiryDate)
                        invoices.append(invoice)
                    }
                }
                   
                // Sort invoices by expiry date
                invoices.sort { $0.expiryDate < $1.expiryDate }
                
                continuation.resume(returning: invoices)
            }
        }
    }
    
    func loadInvoices() async -> [Invoice] {
        guard let userId = Auth.auth().currentUser?.uid else { return [] }
        
        return await withCheckedContinuation { continuation in
            let ref = Database.database().reference().child("invoices").child(userId)
            
            ref.observeSingleEvent(of: .value) { snapshot in
                var invoices: [Invoice] = []
                
                for child in snapshot.children {
                    if let childSnapshot = child as? DataSnapshot,
                       let invoiceData = childSnapshot.value as? [String: Any],
                       let title = invoiceData["title"] as? String,
                       let amount = invoiceData["amount"] as? Double,
                       let processed = invoiceData["processed"] as? Bool,
                       let expiryDateTimestamp = invoiceData["expiryDate"] as? TimeInterval {
                        let expiryDate = Date(timeIntervalSince1970: expiryDateTimestamp)
                        let invoice = Invoice(id: childSnapshot.key, title: title, amount: amount, processed: processed, expiryDate: expiryDate)
                        invoices.append(invoice)
                    }
                }
                
                // Sort invoices by expiry date
                invoices.sort { $0.expiryDate < $1.expiryDate }
                
                continuation.resume(returning: invoices)
            }
        }
    }
    
    func deleteInvoiceReminder(invoiceId: String) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "InvoiceError", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }
        
        let ref = Database.database().reference()
            .child("invoices")
            .child(userId)
            .child(invoiceId)
        
        return try await withCheckedThrowingContinuation { continuation in
            ref.removeValue { error, _ in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }
}

