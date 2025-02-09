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
    let itemContent: (T) -> (category: String, amount: Double?, date: Date?)
    let isCurrent: Bool
    let showNegativeAmount: Bool
    let alignAmountInMiddle: Bool
    let isInvoice: Bool
    @State var budgetfb = BudgetFB()
    
    let onMarkProcessed: ((T) -> Void)?
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
    
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
                        x: -2,
                        y: 4
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.4), lineWidth: 0.8)
                    )
                    
                    HStack {
                        Text(content.category)
                            .foregroundStyle(Color("SecondaryTextColor"))

                        if content.date != nil {
                            Spacer()
                            Text(showNegativeAmount ? "- \(content.amount ?? 0, specifier: "%.2f")" : "\(content.amount ?? 0, specifier: "%.2f")")
                                .foregroundStyle(Color("SecondaryTextColor"))
                            Spacer()
                            Text(dateFormatter.string(from: content.date!))
                                .foregroundStyle(Color("SecondaryTextColor"))
                        } else {
                            if alignAmountInMiddle {
                                Spacer()
                                Text(showNegativeAmount ? "- \(content.amount ?? 0, specifier: "%.2f")" : "\(content.amount ?? 0, specifier: "%.2f")")
                                    .foregroundStyle(Color("SecondaryTextColor"))
                                Spacer()
                            } else {
                                Spacer()
                                Text(showNegativeAmount ? "- \(content.amount ?? 0, specifier: "%.2f")" : "\(content.amount ?? 0, specifier: "%.2f")")
                                    .foregroundStyle(Color("SecondaryTextColor"))
                            }
                        }
                    }
                    .padding()
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 3)
                
                if isInvoice {
                    HStack {
                        Spacer()
                        Button(action: {
                            onMarkProcessed?(item)
                        }) {
                            ButtonView(buttontext: "Mark as processed", maxWidth: 210, incomeButton: true, height: 25)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        Spacer()
                    }
                    .padding(.bottom, 10)
                }
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
            (category: income.category, amount: income.amount, date: Date())
        },
        isCurrent: true,
        showNegativeAmount: false,
        alignAmountInMiddle: false,
        isInvoice: false,
        onMarkProcessed: nil
    )
}
