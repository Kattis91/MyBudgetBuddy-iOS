//
//  ExpensesTabView.swift
//  MyBudget
//
//  Created by Katya Durneva Svedmark on 2024-12-05.
//

import SwiftUI

struct ExpensesTabView: View {
    
    @State private var totalExpenses: Double = 0.0
    
    @State private var selectedView: ExpenseViewType = .fixed
    
    var body: some View {
        
        Text("Total expenses: \(totalExpenses,  specifier: "%.2f")")
            .font(.largeTitle)
            .bold()
            .padding()
        
        HStack {
            Button(action: {
                selectedView = .fixed
            }) {
                Text("Fixed expenses")
                    .background(selectedView == .fixed ? Color.yellow : Color.white)
                    .padding(.horizontal, 24)
            }
            
            Spacer()
            
            Button(action: {
                selectedView = .variable
            }) {
                Text("Variable expenses")
                    .background(selectedView == .variable ? Color.yellow : Color.white)
                    .padding(.horizontal, 24)
            }
        }
        // Display the selected view
       if selectedView == .fixed {
           FixedExpensesPreviewWrapper(totalExpenses: $totalExpenses)
       } else {
           VariableExpensesPreviewWrapper(totalExpenses: $totalExpenses)
       }
    }
}

#Preview {
    ExpensesTabView()
}
