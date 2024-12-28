//
//  NewBudgetPeriodView.swift
//  MyBudget
//
//  Created by Katya Durneva Svedmark on 2024-12-28.
//

import SwiftUI

struct NewBudgetPeriodView: View {
    
    @Binding var isPresented: Bool
    
    @State private var includeIncomes = true
    @State private var includeFastExpenses = true
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    isPresented = false
                }) {
                    Text("X")
                        .foregroundStyle(Color.red)
                        .padding(.trailing)
                }
            }
            
            HStack {
                Text("Transfer Settings")
                    .fontDesign(.rounded)
                    .tracking(1.5)
                Spacer()
            }
            .padding(.horizontal, 45)
            Toggle("Include Incomes", isOn: $includeIncomes)
                .tint(Color("CustomGreen"))
                .padding(.horizontal, 45)
            Toggle("Include Fast Expenses", isOn: $includeFastExpenses)
                .tint(Color("CustomGreen"))
                .padding(.horizontal, 45)
                .padding(.bottom, 10)
            
            
            Button(action: {
                
            }) {
                ButtonView(buttontext: "Start New Period", maxWidth: 180)
            }
        }
        .scrollContentBackground(.hidden)
        .frame(maxWidth: .infinity)
        .frame(height: 250)
        .background(Color("TabColor"))
    }
}

#Preview {
    NewBudgetPeriodView(isPresented: .constant(true))
}
