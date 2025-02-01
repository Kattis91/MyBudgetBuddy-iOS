//
//  InvoiceReminderView.swift
//  MyBudget
//
//  Created by Katya Durneva Svedmark on 2025-01-30.
//

import SwiftUI

struct InvoiceReminderView: View {

    @State private var title: String = ""
    @State private var payDate: Date = Date()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        
        VStack {
            CustomTextFieldView(placeholder: "Title", text: $title, systemName: "bell.badge")
            
            VStack {
                DatePicker("Last payment day", selection: $payDate, displayedComponents: .date)
            }
            .padding(.horizontal, 28)
            
            ButtonView(buttontext: "Save".uppercased(), expenseButton: true)
        }
        .padding(.top, 50)
        
        List {
            
        }

    }
}



#Preview {
    InvoiceReminderView()
}
