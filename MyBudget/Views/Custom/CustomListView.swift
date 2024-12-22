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
                HStack {
                    Text(content.category)
                    Spacer()
                    Text(showNegativeAmount ? "- \(content.amount, specifier: "%.2f")" : "\(content.amount, specifier: "%.2f")")
                }
                .padding()
            }
            .onDelete(perform: deleteAction)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color("TabColor"))
            )
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
        }
        .scrollContentBackground(.hidden)
        .padding(.horizontal, 10)
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
