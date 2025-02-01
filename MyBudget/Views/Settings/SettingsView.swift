//
//  SettingsView.swift
//  MyBudget
//
//  Created by Katya Durneva Svedmark on 2024-12-18.
//

import SwiftUI

struct SettingsView: View {
    
    @Environment(\.dismiss) var dismiss
    @State var budgetfb: BudgetFB
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink(destination: CategoryManagementView(budgetfb: budgetfb)) {
                        HStack {
                            Image(systemName: "folder")
                                .foregroundColor(.purple)
                            Text("Manage Categories")
                        }
                    }
                } header: {
                    Text("Categories")
                }
                
                Section {
                    NavigationLink(destination: InvoiceReminderView()) {
                        HStack {
                            Image(systemName: "bell.badge")
                                .foregroundColor(.purple)
                            Text("Invoice Reminders")
                        }
                    }
                } header: {
                    Text("Extra features")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView(budgetfb: BudgetFB())
}
