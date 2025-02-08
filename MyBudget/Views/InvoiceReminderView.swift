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
    @State private var unprocessedInvoices: [Invoice] = []
    @State private var processedInvoices: [Invoice] = []
    @Environment(\.presentationMode) var presentationMode
    
    @State private var selectedTab = 0
    
    @State var errorMessage = ""
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    var body: some View {
        VStack {
            // Input Form Section
            VStack {
                Text("Manage your invoices:")
                    .font(.title3)
                    .padding(.bottom, 45)
                
                CustomTextFieldView(placeholder: "Title", text: $title, onChange: { errorMessage = ""}, systemName: "bell.badge")
                CustomTextFieldView(placeholder: "Amount", text: $amount, onChange: { errorMessage = ""}, systemName: "dollarsign.circle")
                
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
                            Color(red: 245/255, green: 247/255, blue: 245/255),
                            Color(red: 240/255, green: 242/255, blue: 240/255)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.25), radius: 1, x: -2, y: 4)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.4), lineWidth: 0.8)
                )
                .tint(.pink)
                .padding(.horizontal, 25)
                
                ErrorMessageView(errorMessage: errorMessage, height: 15)
                
                Button(action: {
                    
                    if title.isEmpty {
                        errorMessage = "Please enter a title"
                        return
                    }
                    
                    guard let invoiceAmount = Double(amount) else {
                        errorMessage = "Amount must be a number"
                        return
                    }
                    
                    if invoiceAmount <= 0.00 {
                        errorMessage = "Amount must be greater than zero"
                        return
                    }
                    
                    budgetfb.saveInvoiceReminder(title: title, amount: invoiceAmount, expiryDate: expiryDate)
                    
                    title = ""
                    amount = ""
                    
                    Task {
                        await loadInvoices()
                    }
                }) {
                    ButtonView(buttontext: "Save".uppercased(), expenseButton: true)
                        .padding(.top, 30)
                }
            }
            .padding(.top, 50)
            
            Picker("Invoices", selection: $selectedTab) {
                Text("Pending Invoices").tag(0)
                Text("Processed Invoices").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal, 28)
            .padding(.top, 30)
            
            switch selectedTab {
            case 0:
                // Unprocessed Invoices Section
                Text(unprocessedInvoices.isEmpty ? "You have no pending invoices." : "Pending invoices:")
                    .font(.title2)
                    .padding(.top)
                
                if !unprocessedInvoices.isEmpty {
                    CustomListView(
                        items: unprocessedInvoices,
                        deleteAction: { offsets in
                            deleteUnprocessedInvoices(at: offsets)
                        },
                        itemContent: { invoice in
                            (category: invoice.title, amount: invoice.amount, date: invoice.expiryDate)
                        },
                        isCurrent: true,
                        showNegativeAmount: false,
                        alignAmountInMiddle: true,
                        isInvoice: true,
                        onMarkProcessed: { item in
                            if let invoice = item as? Invoice {
                                Task {
                                    do {
                                        try await budgetfb.updateInvoiceStatus(invoiceId: invoice.id, processed: true)
                                        await loadInvoices()
                                    } catch {
                                        print("Error updating invoice: \(error.localizedDescription)")
                                    }
                                }
                            }
                        }
                    )
                }
            case 1:
                // Processed Invoices Section
                if !processedInvoices.isEmpty {
                    Text("Processed invoices:")
                        .font(.title2)
                        .padding(.top)
                    
                    CustomListView(
                        items: processedInvoices,
                        deleteAction: { offsets in
                            deleteProcessedInvoices(at: offsets)
                        },
                        itemContent: { invoice in
                            (category: invoice.title, amount: invoice.amount, date: invoice.expiryDate)
                        },
                        isCurrent: true,
                        showNegativeAmount: false,
                        alignAmountInMiddle: true,
                        isInvoice: false,
                        onMarkProcessed: nil
                    )
                }
            default:
                EmptyView()
            }
            
            Spacer()
        }
        .task {
            await loadInvoices()
        }
    }
    
    private func loadInvoices() async {
        unprocessedInvoices = await budgetfb.loadInvoicesByStatus(processed: false)
        processedInvoices = await budgetfb.loadInvoicesByStatus(processed: true)
    }
    
    private func deleteUnprocessedInvoices(at offsets: IndexSet) {
        Task {
            for index in offsets {
                guard index < unprocessedInvoices.count else { continue }
                let invoiceToDelete = unprocessedInvoices[index]
                do {
                    try await budgetfb.deleteInvoiceReminder(invoiceId: invoiceToDelete.id)
                    await loadInvoices()
                } catch {
                    print("Error deleting unprocessed invoice: \(error.localizedDescription)")
                }
            }
        }
    }
        
    private func deleteProcessedInvoices(at offsets: IndexSet) {
        Task {
            for index in offsets {
                guard index < processedInvoices.count else { continue }
                let invoiceToDelete = processedInvoices[index]
                do {
                    try await budgetfb.deleteInvoiceReminder(invoiceId: invoiceToDelete.id)
                    await loadInvoices()
                } catch {
                    print("Error deleting processed invoice: \(error.localizedDescription)")
                }
            }
        }
    }
}

#Preview {
    InvoiceReminderView()
        .environmentObject(BudgetManager())
}
