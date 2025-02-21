//
//  DeleteAccountView.swift
//  MyBudget
//
//  Created by Katya Durneva Svedmark on 2025-02-21.
//

import SwiftUI

struct DeleteAccountView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        
        VStack {
            Text("Delete account here")
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    Task {
                        dismiss()
                    }
                }) {
                    Image(systemName: "xmark")
                        .foregroundStyle(.red)
                }
            }
        }
    }
}

#Preview {
    DeleteAccountView()
}
