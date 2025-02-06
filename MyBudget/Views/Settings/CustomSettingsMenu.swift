//
//  CustomSettingsMenu.swift
//  MyBudget
//
//  Created by Katya Durneva Svedmark on 2025-01-10.
//

import SwiftUI

struct CustomSettingsMenu: View {
    @State private var showCategoryManagement = false
    @State private var showInvoiceReminders = false
    var budgetfb: BudgetFB
    var onCategoriesUpdate: () async -> Void
    
    var body: some View {
        Menu {
            Button(action: {
                showCategoryManagement = true
            }) {
                Label("Manage Categories", systemImage: "folder")
            }
            
            Button(action: {
                showInvoiceReminders = true
            }) {
                Label("Invoice Reminders", systemImage: "bell.badge")
            }
        } label: {
            Image(systemName: "gearshape")
                .font(.title2)
                .foregroundColor(.primary)
                .padding(8)
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
                .cornerRadius(8)
                .shadow(
                    color: .black.opacity(0.25),
                    radius: 1,
                    x: -2,
                    y: 4
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.white.opacity(0.4), lineWidth: 0.8)
                )
        }
        .sheet(isPresented: $showCategoryManagement) {
            CategoryManagementView(
                budgetfb: budgetfb,
                onCategoriesUpdate: onCategoriesUpdate
            )
        }
        .sheet(isPresented: $showInvoiceReminders) {
            InvoiceReminderView()
        }
    }
}

#Preview {
    CustomSettingsMenu(
        budgetfb: BudgetFB(),
        onCategoriesUpdate: {
            // Simulate category update in preview
            print("Categories would update here")
        }
    )
}
