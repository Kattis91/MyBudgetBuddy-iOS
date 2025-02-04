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
                Task {
                    await budgetManager.loadInvoices()
                }
            }) {
                ButtonView(buttontext: "Save".uppercased(), expenseButton: true)
            }
        }
        .padding(.top, 50)
        
        Text(budgetManager.invoices.isEmpty ? "You have no invoices right now." : "Your invoices:")
            .font(.title2)
            .padding(.top)
        
        CustomListView(
            items: budgetManager.invoices,
            deleteAction: deleteInvoiceItem, // Add your delete action here
            itemContent: { invoice in
                (category: invoice.title, amount: nil, date: invoice.expiryDate)
            },
            isCurrent: true,
            showNegativeAmount: false
        )
        .task {
            await budgetManager.loadInvoices()
        }
    }
    
    // Bridge function
    private func deleteInvoiceItem(at offsets: IndexSet) {
        budgetfb.deleteInvoiceReminders(at: offsets)
    }
}

#Preview {
    InvoiceReminderView()
        .environmentObject(BudgetManager())
}
