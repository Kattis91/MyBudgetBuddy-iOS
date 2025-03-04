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
    
    @Environment(\.colorScheme) var colorScheme
    var isDarkMode: Bool {
        return colorScheme == .dark
    }
    
    var body: some View {
        
        List {
            ForEach(items) { item in
                let content = itemContent(item)
                
                ZStack {
                    LinearGradient(
                        gradient: Gradient(colors: colorScheme == .dark ? [
                            Color(.darkGray), Color(.black)
                        ] : [
                            Color(red: 245/255, green: 247/255, blue: 245/255),
                            Color(red: 240/255, green: 242/255, blue: 240/255)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .cornerRadius(16)
                    .shadow(
                        color: colorScheme == .dark ?
                            .black.opacity(0.35) :
                            .black.opacity(0.25),
                        radius: colorScheme == .dark ? 2 : 1,
                        x: -2,
                        y: 4
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                colorScheme == .dark ?
                                    Color.white.opacity(0.3) :
                                    Color.white.opacity(0.4),
                                lineWidth: isDarkMode ? 0.6 : 0.8
                            )
                    )
                    
                    HStack {
                        Text(content.category)
                            .foregroundStyle(Color("PrimaryTextColor"))

                        if content.date != nil {
                            Spacer()
                            Text(showNegativeAmount ? "- \(content.amount ?? 0, specifier: "%.2f")" : "\(content.amount ?? 0, specifier: "%.2f")")
                                .foregroundStyle(Color("PrimaryTextColor"))
                            Spacer()
                            Text(dateFormatter.string(from: content.date!))
                                .foregroundStyle(Color("PrimaryTextColor"))
                        } else {
                            if alignAmountInMiddle {
                                Spacer()
                                Text(showNegativeAmount ? "- \(content.amount ?? 0, specifier: "%.2f")" : "\(content.amount ?? 0, specifier: "%.2f")")
                                    .foregroundStyle(Color("PrimaryTextColor"))
                                Spacer()
                            } else {
                                Spacer()
                                Text(showNegativeAmount ? "- \(content.amount ?? 0, specifier: "%.2f")" : "\(content.amount ?? 0, specifier: "%.2f")")
                                    .foregroundStyle(Color("PrimaryTextColor"))
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 14)
                }
                .padding(.vertical, 3)
                
                if isInvoice {
                    HStack {
                        Spacer()
                        Button(action: {
                            onMarkProcessed?(item)
                        }) {
                            ButtonView(buttontext: String(localized: "Mark as processed"), maxWidth: 210, incomeButton: true, height: 25)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        Spacer()
                    }
                    .padding(.bottom, 10)
                }
            }
            .onDelete(perform: deleteAction)
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: 5, leading: isDarkMode ? 15 : 20, bottom: 5, trailing: isDarkMode ? 15 : 20))
        }
        .scrollContentBackground(.hidden)
        .listStyle(PlainListStyle())
        .background(Color.clear)
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
