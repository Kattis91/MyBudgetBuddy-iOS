//
//  SectionView.swift
//  MyBudget
//
//  Created by Katya Durneva Svedmark on 2025-01-20.
//

import SwiftUI

struct SectionView: View {
    let title: String
    let categories: [String]
    let onEdit: (String) -> Void
    let onDelete: (String) -> Void
    let onAdd: () -> Void
    let headerText: String
    
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Section {
            ForEach(categories, id: \.self) { category in
                HStack {
                    Text(category)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Color("PrimaryTextColor"))
                    Spacer()
                    HStack(spacing: 16) {
                        Button(action: { onEdit(category) }) {
                            Image(systemName: "square.and.pencil")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundStyle(Color("PrimaryTextColor"))
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        
                        Button(action: { onDelete(category) }) {
                            Image(systemName: "trash")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundColor(Color("ButtonsBackground"))
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                }
                .padding()
                .background(
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
                            Color.white.opacity(0.2) :
                                Color.white.opacity(0.4),
                            lineWidth: 0.8
                        )
                )
            }
            .padding(.horizontal, 10)
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: 7, leading: 10, bottom: 7, trailing: 10))
            
            Button(action: onAdd) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 20)) // Match other icons size
                    Text("Add \(title)")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity, maxHeight: 20)
                .padding()
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [.buttonGradientLight, .buttonGradientDark]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.4), radius: 1, x: -2, y: 4)
                .padding(.top, 15)
            }
            .padding(.horizontal, 20)
            .listRowSeparator(.hidden)
        } header: {
            Text(headerText)
                .font(.title2)
                .textCase(nil)  // This will override any inherited text transformation
                .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
                .padding(.leading, 10)
        }
    }
}



#Preview {
    SectionView(
        title: "Test",
        categories: ["A", "B", "C"],
        onEdit: { _ in },
        onDelete: { _ in },
        onAdd: { },
        headerText: "Incomes categorier"
    )
}
