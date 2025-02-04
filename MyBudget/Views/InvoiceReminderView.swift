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
            }) {
                ButtonView(buttontext: "Save".uppercased(), expenseButton: true)
            }
        }
        .padding(.top, 50)
        
        Text("Your invoices:")
            .font(.title)
            .padding(.top)
        
        CustomListView(
            items: budgetManager.invoices,
            deleteAction: { _ in }, // Add your delete action here
            itemContent: { invoice in
                (category: invoice.title, amount: nil, date: invoice.expiryDate)
            },
            isCurrent: true,
            showNegativeAmount: false
        )
        .onAppear() {
            Task {
                await budgetManager.loadInvoices()
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
