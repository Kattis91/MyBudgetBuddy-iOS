//
//  InvoiceReminderView.swift
//  MyBudget
//
//  Created by Katya Durneva Svedmark on 2025-01-30.
//

import SwiftUI

struct InvoiceReminderView: View {
    
    @State var budgetfb = BudgetFB()
    @EnvironmentObject var budgetManager: BudgetManager

    @State private var title: String = ""
    @State private var expiryDate: Date = Date()
    @Environment(\.presentationMode) var presentationMode
    @State private var invoices: [String] = []
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    var body: some View {
        
        VStack {
            CustomTextFieldView(placeholder: "Title", text: $title, systemName: "bell.badge")
            
            VStack {
                DatePicker("Last payment day", selection: $expiryDate, displayedComponents: .date)
            }
            .padding(.horizontal, 28)
            
            Button(action: {
                budgetfb.saveInvoiceReminder(title: title, expiryDate: expiryDate)
            }) {
                ButtonView(buttontext: "Save".uppercased(), expenseButton: true)
            }
        }
        .padding(.top, 50)
        
        Text("Your invoices:")
            .font(.title)
            .padding(.top)
        
        List(budgetManager.invoices) { invoice in
            HStack {
                Text(invoice.title)
                Spacer()
                Text(dateFormatter.string(from: invoice.expiryDate))
            }
        }
        .task {
            await budgetManager.loadInvoices()
        }

    }
}

#Preview {
    InvoiceReminderView()
        .environmentObject(BudgetManager())
}
