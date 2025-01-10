//
//  SettingsView.swift
//  MyBudget
//
//  Created by Katya Durneva Svedmark on 2024-12-18.
//

import SwiftUI

struct SettingsView: View {
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink(destination: CategoryManagementView()) {
                        HStack {
                            Image(systemName: "folder")
                                .foregroundColor(.purple)
                            Text("Manage Categories")
                        }
                    }
                } header: {
                    Text("Categories")
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
    SettingsView()
}
