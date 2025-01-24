//
//  CustomListView.swift
//  MyBudget
//
//  Created by Katya Durneva Svedmark on 2024-12-22.
//

import SwiftUI

struct CustomListView<T: Identifiable>: View {
    
    let items: [T]
    let deleteAction: ((IndexSet) -> Void)?
    let itemContent: (T) -> (category: String, amount: Double)
    let showNegativeAmount: Bool
    
    var body: some View {
        
        List {
            ForEach(items) { item in
                let content = itemContent(item)
                
                ZStack {
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 245/255, green: 247/255, blue: 245/255), // Light gray
                            Color(red: 240/255, green: 242/255, blue: 240/255)  // Slightly darker gray
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .cornerRadius(16)
                    .shadow(
                        color: .black.opacity(0.25),
                        radius: 1,
                        x: 0,
                        y: 4
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.4), lineWidth: 0.8)
                    )
                    
                    HStack {
                        Text(content.category)
                          
                        Spacer()
                        Text(showNegativeAmount ? "- \(content.amount, specifier: "%.2f")" : "\(content.amount, specifier: "%.2f")")
                    }
                    .padding()
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 3)
            }
            .onDelete(perform: deleteAction)
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
        }
        .scrollContentBackground(.hidden)
    }
}

#Preview {
    CustomListView(
        items: [
            Income(id: "1", amount: 1000, category: "Salary"),
            Income(id: "2", amount: 500, category: "Bonus")
        ],
        deleteAction: { _ in },
        itemContent: { income in
            (category: income.category, amount: income.amount)
        },
        showNegativeAmount: false
    )
}
