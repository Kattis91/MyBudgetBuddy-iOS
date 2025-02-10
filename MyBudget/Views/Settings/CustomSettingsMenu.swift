//
//  CustomSettingsMenu.swift
//  MyBudget
//
//  Created by Katya Durneva Svedmark on 2025-01-10.
//

import SwiftUI

struct CustomSettingsMenu: View {
    var budgetfb: BudgetFB
    var onCategoriesUpdate: () async -> Void
    @State private var showPopover = false
    @State var showCategoryManagement = false
    @State private var showInvoiceReminders = false
    @State private var selectedItem: Int? = nil
    
    @Environment(\.colorScheme) var colorScheme
    var isDarkMode: Bool {
        return colorScheme == .dark
    }
    
    var body: some View {
        Button {
            showPopover.toggle()
        } label: {
            Image(systemName: "gearshape")
                .font(.title2)
                .foregroundColor(Color("SecondaryTextColor"))
                .padding(3)
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
        .popover(isPresented: $showPopover, attachmentAnchor: .point(.bottom)) {
            VStack(spacing: 0) {
                Button(action: {
                    withAnimation(.spring(response: 0.3)) {
                        selectedItem = 0
                    }
                    showPopover = false
                    showCategoryManagement = true
                }) {
                    HStack {
                        Image(systemName: "folder")
                            .frame(width: 24)
                            .foregroundColor(Color("CustomGreen"))
                        Text("Manage Categories")
                            .foregroundColor(Color("SecondaryTextColor"))
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(selectedItem == 0 ? Color.gray.opacity(0.1) : Color.clear)
                }
                
                Divider()
                    .background(Color.gray.opacity(0.4))
                
                Button(action: {
                    withAnimation(.spring(response: 0.3)) {
                        selectedItem = 1
                    }
                    showPopover = false
                    showInvoiceReminders = true
                }) {
                    HStack {
                        Image(systemName: "bell")
                            .frame(width: 24)
                            .foregroundColor(Color("ButtonsBackground"))
                        Text("Invoice Reminders")
                            .foregroundColor(Color("SecondaryTextColor"))
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                   
                }
            }
            .frame(width: 250)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 245/255, green: 247/255, blue: 245/255),
                        Color(red: 240/255, green: 242/255, blue: 240/255)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.4), lineWidth: 0.8)
            )
            .presentationCompactAdaptation(.popover)
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
