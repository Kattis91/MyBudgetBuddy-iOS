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
    @State private var amount: String = ""
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
            
            CustomTextFieldView(placeholder: "Amount", text: $amount, systemName: "dollarsign.circle")
            
            HStack {
                Image(systemName: "clock")
                    .foregroundColor(.black.opacity(0.5))
                Text("Due to:")
                    .foregroundColor(.black.opacity(0.5))
                DatePicker(
                    "",
                    selection: $expiryDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.automatic)
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 245/255, green: 247/255, blue: 245/255), // Light gray
                        Color(red: 240/255, green: 242/255, blue: 240/255)  // Slightly darker gray
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
            .shadow(
                color: .black.opacity(0.25),
                radius: 1,
                x: -2,
                y: 4
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.4), lineWidth: 0.8)
            )
            .tint(.pink)
            .padding(.horizontal, 25)
            
            /*
            VStack(alignment: .leading, spacing: 12) {
                Text("Last payment day")
                    .font(.body)
                
                DatePicker(
                    "",
                    selection: $expiryDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.compact)
                .labelsHidden()
                .tint(.pink) // Matches your accent color
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
            }
            .padding(.horizontal)
             
            */
            
            
            Button(action: {
                if let invoiceAmount = Double(amount) {
                    budgetfb.saveInvoiceReminder(title: title, amount: invoiceAmount, expiryDate: expiryDate)
                }
                Task {
                    await budgetManager.loadInvoices()
                }
            }) {
                ButtonView(buttontext: "Save".uppercased(), expenseButton: true)
                    .padding(.top, 30)
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
                (category: invoice.title, amount: invoice.amount, date: invoice.expiryDate)
            },
            isCurrent: true,
            showNegativeAmount: false,
            alignAmountInMiddle: true
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
