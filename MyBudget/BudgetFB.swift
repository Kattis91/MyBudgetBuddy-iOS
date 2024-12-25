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
    var groupedIncome: [String: Double] = [:] // Summerad inkomst per kategori

    
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
    
    func saveExpenseData(amount: Double, category: String, isfixed: Bool) {
        var ref: DatabaseReference!
        
        ref = Database.database().reference()
        
        let userid = Auth.auth().currentUser!.uid
        
        let expenseEntry: [String: Any] = [
            "amount": amount,
            "category": category,
            "isfixed": isfixed
            ]
        
        ref.child("expenses").child(userid).childByAutoId().setValue(expenseEntry)
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
            
            // Create temporary arrays/dictionaries
            var newIncomeList: [Income] = []
            var newGroupedIncome: [String: Double] = [:]
            var newTotalIncome: Double = 0.0
            
            // Process all income data
            for incomeitem in incomedata.children {
                let incomesnap = incomeitem as! DataSnapshot
                
                guard let incomeDataDict = incomesnap.value as? [String: Any] else {
                    print("Failed to get income data")
                    continue
                }
                
                let fetchedIncome = Income(
                    id: incomesnap.key,
                    amount: incomeDataDict["amount"] as? Double ?? 0.0,
                    category: incomeDataDict["category"] as? String ?? "Unknown"
                )
                
                newIncomeList.append(fetchedIncome)
                
                // Group and sum by category
                let category = fetchedIncome.category
                newGroupedIncome[category] = (newGroupedIncome[category] ?? 0.0) + fetchedIncome.amount
            }
            
            // Calculate new total
            newTotalIncome = newIncomeList.reduce(0.0) { $0 + $1.amount }
            
            // Update all UI elements at once on the main thread
            await MainActor.run {
                self.incomeList = newIncomeList
                self.groupedIncome = newGroupedIncome
                self.totalIncome = newTotalIncome
            }
            
        } catch {
            print("Error loading income data: \(error.localizedDescription)")
        }
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
    
    func loadExpenseData() async {
        
        guard let userid = Auth.auth().currentUser?.uid else { return }
        
        var ref: DatabaseReference!
        
        ref = Database.database().reference()
        
        do {
            let expensedata = try await ref.child("expenses").child(userid).getData()
            print(expensedata.childrenCount)
            
            DispatchQueue.main.async {
                self.variableExpenseList = []
                self.fixedExpenseList = []
            }
            
            for expenseitem in expensedata.children {
                let expensesnap = expenseitem as! DataSnapshot
                
                // Access the "income data" child
                guard let expenseDataDict = expensesnap.value as? [String: Any]
                else {
                    print("Failed to get income data")
                    continue
                }
                
                print(expenseDataDict)
                
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
            }
            
            // Calculate total expense
            
            let FixedExpensesSum = fixedExpenseList.reduce(0.0) { (sum, expense) in
                 return sum + expense.amount
            }
             
            let VariableExpensesSum = variableExpenseList.reduce(0.0) { (sum, expense) in
                 return sum + expense.amount
            }
             
            let totExpenses = FixedExpensesSum + VariableExpensesSum
            totalExpenses = totExpenses
        
        } catch {
            // Something went wrong
            print("Something went wrong!")
        }
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
    
}
