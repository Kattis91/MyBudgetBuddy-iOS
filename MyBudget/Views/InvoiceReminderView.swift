//
//  InvoiceReminderView.swift
//  MyBudget
//
//  Created by Katya Durneva Svedmark on 2025-01-30.
//

import SwiftUI

struct InvoiceReminderView: View {

    @State private var title: String = ""
    @State private var expiryDate: Date = Date()
    @Environment(\.presentationMode) var presentationMode
    @State var budgetfb = BudgetFB()
    
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
        
        List {
            
        }

    }
}



#Preview {
    InvoiceReminderView()
}
