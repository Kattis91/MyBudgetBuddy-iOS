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
                completion(error.localizedDescription) // Return Firebase error
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
            
            for offset in offsets {
                let incomeItem = self.incomeList[offset]
                ref.child("budgetPeriods")
                    .child(userId)
                    .child(budgetPeriod.id)
                    .child("incomes")
                    .child(incomeItem.id)
                    .removeValue()
            }
            
            // Update local data
            self.incomeList.remove(atOffsets: offsets)
            self.totalIncome = self.incomeList.reduce(0.0) { $0 + $1.amount }
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
        let userId = Auth.auth().currentUser?.uid
        guard let userId else { return }
        
        var ref: DatabaseReference!
        ref = Database.database().reference()
        
        loadCurrentBudgetPeriod { [weak self] budgetPeriod in
            guard let budgetPeriod = budgetPeriod,
                  let self = self else { return }
            
            var expenseList: [Expense] // Common array for handling expenses
            
            // Determine which list to use based on `listType`
            switch listType {
            case "fixed":
                expenseList = fixedExpenseList
            case "variable":
                expenseList = variableExpenseList
            default:
                print("Invalid list type")
                return
            }
            
            for offset in offsets {
                let expenseItem = expenseList[offset]
                ref.child("budgetPeriods").child(userId).child(budgetPeriod.id).child(isfixed ? "fixedExpenses" : "variableExpenses").child(expenseItem.id).removeValue()
            }
            
            // Update local data
            if listType == "fixed" {
                fixedExpenseList.remove(atOffsets: offsets)
            } else if listType == "variable" {
                variableExpenseList.remove(atOffsets: offsets)
            }
            
            // Recalculate total expenses
            totalExpenses = (fixedExpenseList + variableExpenseList)
                .reduce(0.0) { $0 + $1.amount }
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
        
        newBudgetRef.setValue(budgetPeriod.toDictionary()) { [self] error, _ in
            guard error == nil else {
                completion(false)
                return
            }
            
            if !transferData.incomes && !transferData.expenses {
                completion(true)
                return
            }
            
            loadCurrentBudgetPeriod { currentPeriod in
                guard let currentId = currentPeriod?.id else {
                    completion(true)
                    return
                }
                
                let currentRef = ref.child("budgetPeriods").child(userId).child(currentId)
                let group = DispatchGroup()
                
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
                
                // Set the ID from the snapshot key
                budgetPeriod.id = periodData.key
                completion(budgetPeriod)
            }
    }
    
    func saveHistoricalPeriods(_ budgetPeriod: BudgetPeriod) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let ref = Database.database().reference()
        
        // Generate a new unique ID for this historical period
        let periodRef = ref.child("historicalPeriods").child(userId).childByAutoId()
        
        // Save the complete income and expense data, not just IDs
        let periodData: [String: Any] = [
            "startDate": budgetPeriod.startDate.timeIntervalSince1970,
            "endDate": budgetPeriod.endDate.timeIntervalSince1970,
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
        
        periodRef.setValue(periodData) { error, _ in
            if let error = error {
                print("Error saving period: \(error.localizedDescription)")
            } else {
                print("Period saved successfully!")
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
                variableExpenses: variableExpenses
            )
            
            periods.append(period)
        }
        
        return periods
    }
    
    func deleteHistoricalPeriod(at offsets: IndexSet, from periods: [BudgetPeriod]) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let ref = Database.database().reference()
        
        // Get a snapshot of the current data to find the correct key to delete
        ref.child("historicalPeriods").child(userId).getData { error, snapshot in
            guard let snapshot = snapshot else { return }
            
            // Convert the periods at the specified offsets to an array of dates for comparison
            let periodsToDelete = offsets.map { periods[$0] }
            
            // Iterate through the snapshot to find matching periods
            for case let historicalSnap as DataSnapshot in snapshot.children {
                guard let historicalData = historicalSnap.value as? [String: Any],
                      let startDate = historicalData["startDate"] as? TimeInterval,
                      let endDate = historicalData["endDate"] as? TimeInterval else {
                    continue
                }
                
                // Check if this snapshot matches any of our periods to delete
                for periodToDelete in periodsToDelete {
                    if startDate == periodToDelete.startDate.timeIntervalSince1970 &&
                       endDate == periodToDelete.endDate.timeIntervalSince1970 {
                        // Found a match, delete this node
                        ref.child("historicalPeriods").child(userId).child(historicalSnap.key).removeValue { error, _ in
                            if let error = error {
                                print("Error deleting period: \(error.localizedDescription)")
                            } else {
                                print("Period deleted successfully")
                            }
                        }
                    }
                }
            }
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
}

