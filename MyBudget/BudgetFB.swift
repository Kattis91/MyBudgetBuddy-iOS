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
        let categoryRef = ref.child("incomes").child(userId).child(category)
        
        // First update the database
        categoryRef.observeSingleEvent(of: .value) { [weak self] snapshot in
            if let existingData = snapshot.value as? [String: Any],
               let existingAmount = existingData["amount"] as? Double {
                // Update sum
                let updatedAmount = existingAmount + amount
                categoryRef.setValue(["amount": updatedAmount, "category": category]) { error, _ in
                    if error == nil {
                        // After successful save, reload data on main thread
                        Task { @MainActor in
                            await self?.loadIncomeData()
                        }
                    }
                }
            } else {
                // Create new category if it doesn't exist
                categoryRef.setValue(["amount": amount, "category": category]) { error, _ in
                    if error == nil {
                        // After successful save, reload data on main thread
                        Task { @MainActor in
                            await self?.loadIncomeData()
                        }
                    }
                }
            }
        }
    }

    func loadIncomeData() async {
        guard let userid = Auth.auth().currentUser?.uid else { return }
        let ref = Database.database().reference()
        
        do {
            let incomedata = try await ref.child("incomes").child(userid).getData()
            
            // Process all income data and create the final arrays/dictionaries
            let processedData = await processIncomeData(incomedata)
            
            // Update all UI elements at once on the main thread
            await MainActor.run {
                self.incomeList = processedData.incomes
                self.groupedIncome = processedData.grouped
                self.totalIncome = processedData.total
            }
            
        } catch {
            print("Error loading income data: \(error.localizedDescription)")
        }
    }
    
    // Helper function to process income data
    func processIncomeData(_ snapshot: DataSnapshot) async -> (incomes: [Income], grouped: [String: Double], total: Double) {
        var incomeList: [Income] = []
        var groupedIncome: [String: Double] = [:]
        var totalIncome: Double = 0.0
        
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
            
            // Group and sum by category
            let category = fetchedIncome.category
            groupedIncome[category] = (groupedIncome[category] ?? 0.0) + fetchedIncome.amount
        }
        
        totalIncome = incomeList.reduce(0.0) { $0 + $1.amount }
                
        return (incomeList, groupedIncome, totalIncome)
    }
    
    
    func deleteIncome(at offsets: IndexSet) {
       let userid = Auth.auth().currentUser?.uid
       guard let userid else { return }
       
       var ref: DatabaseReference!
       ref = Database.database().reference()
       
       for offset in offsets {
           print("DELETE \(offset)")
           let incomeItem = incomeList[offset]
           print(incomeItem.id)
           print(incomeItem.category)
           ref.child("incomes").child(userid).child(incomeItem.id).removeValue()
       }
       
       // Update local data
       incomeList.remove(atOffsets: offsets)
       
       // Recalculate total income
       totalIncome = incomeList.reduce(0.0) { $0 + $1.amount }
   }
    
    func saveExpenseData(amount: Double, category: String, isfixed: Bool) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let ref = Database.database().reference()
        let categoryRef = ref.child("expenses").child(userId).child(category)
        
        categoryRef.observeSingleEvent(of: .value) { [weak self] snapshot in
            if let existingData = snapshot.value as? [String: Any],
               let existingAmount = existingData["amount"] as? Double {
                // Update sum
                let updatedAmount = existingAmount + amount
                categoryRef.setValue(["amount": updatedAmount, "category": category, "isfixed": isfixed]) { error, _ in
                    if error == nil {
                        // After successful save, reload data on main thread
                        Task { @MainActor in
                            await self?.loadExpenseData()
                        }
                    }
                }
            } else {
                // Create new category if it doesn't exist
                categoryRef.setValue(["amount": amount, "category": category, "isfixed": isfixed]) { error, _ in
                    if error == nil {
                        // After successful save, reload data on main thread
                        Task { @MainActor in
                            await self?.loadExpenseData()
                        }
                    }
                }
            }
        }
    }
    
    func loadExpenseData() async {
        
        guard let userid = Auth.auth().currentUser?.uid else { return }
        
        var ref: DatabaseReference!
        
        ref = Database.database().reference()
        
        do {
            let expensedata = try await ref.child("expenses").child(userid).getData()
            
            // Process all expense data and create the final arrays/dictionaries
            let processedData = await processExpenseData(expensedata)
            
            // Update all UI elements at once on the main thread
            await MainActor.run {
                self.fixedExpenseList = processedData.fixedExpenses
                self.variableExpenseList = processedData.variableExpenses
                self.groupedExpense = processedData.grouped
                self.totalExpenses = processedData.total
            }
        } catch {
            // Something went wrong
            print("Error loading income data: \(error.localizedDescription)")
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
    
    
    func deleteExpense(from listType: String, at offsets: IndexSet) {
        let userId = Auth.auth().currentUser?.uid
        guard let userId else { return }

        var ref: DatabaseReference!
        ref = Database.database().reference()

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
            print("DELETE \(offset)")
            print(expenseItem.id)
            print(expenseItem.category)
            ref.child("expenses").child(userId).child(expenseItem.id).removeValue()
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
    
    func saveBudgetPeriod(_ budgetPeriod: BudgetPeriod, completion: @escaping (Bool) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(false)
            return
        }
        let ref = Database.database().reference()
        let budgetRef = ref.child("budgetPeriods").child(userId).child(budgetPeriod.id)

        budgetRef.setValue(budgetPeriod.toDictionary()) { error, _ in
            if let error = error {
                print("Failed to save budget period: \(error.localizedDescription)")
                completion(false)
            } else {
                print("Successfully saved budget period")
                completion(true)
            }
        }
    }
    
    func loadCurrentBudgetPeriod(completion: @escaping (BudgetPeriod?) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(nil)
            return
        }
        let ref = Database.database().reference()
        let budgetPeriodsRef = ref.child("budgetPeriods").child(userId)
        
        budgetPeriodsRef.queryOrdered(byChild: "startDate")
                        .queryLimited(toLast: 1)
                        .observeSingleEvent(of: .value) { snapshot in
            guard let periodData = snapshot.children.allObjects.first as? DataSnapshot,
                  let dict = periodData.value as? [String: Any],
                  let budgetPeriod = BudgetPeriod(dict: dict) else {
                print("Failed to load budget period")
                completion(nil)
                return
            }
            
            completion(budgetPeriod)
        }
    }
    
}

