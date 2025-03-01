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
    
    @Environment(\.dismiss) private var dismiss
    
    @State var showingMarkAsProcessedAlert = false
    @State private var invoiceToMarkAsProcessed: Invoice?
    
    @State private var showScanner = false
    @State private var scannedDueDate: String = ""
    @State private var scannedAmount: String = ""
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    @Environment(\.colorScheme) var colorScheme
    var isDarkMode: Bool {
        return colorScheme == .dark
    }
    
    var body: some View {
        
        NavigationStack {
            VStack {
                // Input Form Section
                VStack {
                    
                    CustomTextFieldView(placeholder: String(localized: "Title"), text: $title, onChange: { errorMessage = ""}, systemName: "bell.badge", maxLength: 50)
                        .padding(.top, 10)
                    CustomTextFieldView(placeholder: String(localized: "Amount"), text: $amount, onChange: { errorMessage = ""}, systemName: "dollarsign.circle", maxLength: 15)
                    
                    HStack {
                        Image(systemName: "clock")
                            .foregroundColor(Color("PrimaryTextColor"))
                        Text("Due to:")
                            .foregroundColor(Color("PrimaryTextColor"))
                        DatePicker(
                            "",
                            selection: $expiryDate,
                            displayedComponents: [.date]
                        )
                        .foregroundStyle(Color("PrimaryTextColor"))
                        .colorMultiply(Color("PrimaryTextColor"))
                    }
                    .tint(.pink)
                    .padding(.trailing, 25)
                    .padding(.leading, 30)
                    .padding(.bottom, 10)
                    
                    Button(action: {
                        showScanner = true
                    }) {
                        VStack {
                            Image(systemName: "qrcode.viewfinder")
                                .font(.system(size: 25))
                                .padding(.vertical, 3)
                            Text("Scan the invoice")
                        }
                    }
                    .sheet(isPresented: $showScanner, onDismiss: {
                        // Improved date conversion
                        if !scannedDueDate.isEmpty {
                            let scanFormatter = DateFormatter()
                            scanFormatter.dateFormat = "yyyy-MM-dd"
                            if let date = scanFormatter.date(from: scannedDueDate) {
                                expiryDate = date
                                print("Successfully updated expiryDate to: \(date)")
                            }
                        }
                        
                        // Handle amount if needed
                        if !scannedAmount.isEmpty {
                            amount = scannedAmount
                        }
                        
                        scannedAmount = ""
                        scannedDueDate = ""
                    }) {
                        InvoiceScannerView(scannedAmount: $scannedAmount, scannedDueDate: $scannedDueDate)
                    }
                    
                    Button(action: {
                        
                        if title.isEmpty {
                            errorMessage = String(localized: "Please enter a title")
                            return
                        }
                        
                        // Replace comma with period to handle European decimal format
                        let normalizedAmount = amount.replacingOccurrences(of: ",", with: ".")
                       
                        guard let invoiceAmount = Double(normalizedAmount) else {
                            errorMessage = String(localized: "Amount must be a number")
                            return
                        }
                        
                        if invoiceAmount <= 0.00 {
                            errorMessage = String(localized: "Amount must be greater than zero")
                            return
                        }
                        
                        budgetfb.saveInvoiceReminder(title: title, amount: invoiceAmount, expiryDate: expiryDate)
                        
                        title = ""
                        amount = ""
                        
                        Task {
                            await loadInvoices()
                        }
                    }) {
                        ButtonView(buttontext: String(localized: "Save").uppercased(), expenseButton: true, height: 41, topPadding: 0)
                    }
                    .padding(.bottom, 5)
                    
                    ErrorMessageView(errorMessage: errorMessage, height: 15)
                }
               
                
                Picker("Invoices", selection: $selectedTab) {
                    Text("Unprocessed Invoices").tag(0)
                    Text("Processed Invoices").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal, 24)
                .padding(.bottom, 30)
                .padding(.top, 10)
                
                switch selectedTab {
                case 0:
                    // Unprocessed Invoices Section
                    if unprocessedInvoices.isEmpty {
                        Text("You have no unprocessed invoices right now." )
                            .font(.title3)
                            .padding(.top)
                            .padding(.horizontal, 20)
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color("PrimaryTextColor"))
                    }
                    
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
                                invoiceToMarkAsProcessed = item
                                showingMarkAsProcessedAlert = true
                            }
                        )
                        .padding(.top, -15)
                        .padding(.horizontal, isDarkMode ? 14 : 5)
                    }
                case 1:
                    // Processed Invoices Section
                    if processedInvoices.isEmpty {
                        Text("You have no processed invoices right now")
                            .font(.title3)
                            .padding(.top)
                            .padding(.horizontal, 20)
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color("PrimaryTextColor"))
                    }
                    
                    if !processedInvoices.isEmpty {
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
                        .padding(.top, -15)
                        .padding(.horizontal, isDarkMode ? 14 : 5)
                    }
                default:
                    EmptyView()
                }
                
                Spacer()
            }
            .alert("Are you sure you want to mark \(invoiceToMarkAsProcessed?.title ?? "this invoice") as processed?", isPresented: $showingMarkAsProcessedAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Yes", role: .destructive) {
                    if let invoice = invoiceToMarkAsProcessed {
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
            }
            .task {
                await loadInvoices()
            }
            .navigationTitle("Manage Invoices")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        Task {
                            dismiss()
                        }
                    }) {
                        Image(systemName: "xmark")
                            .foregroundStyle(Color("ButtonsBackground"))
                    }
                }
            }
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
