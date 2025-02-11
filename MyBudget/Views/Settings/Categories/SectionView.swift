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

    var body: some View {
        Section {
            ForEach(categories, id: \.self) { category in
                HStack {
                    Text(category)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Color("SecondaryTextColor"))
                    Spacer()
                    HStack(spacing: 16) {
                        Button(action: { onEdit(category) }) {
                            Image(systemName: "square.and.pencil")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.blue)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        
                        Button(action: { onDelete(category) }) {
                            Image(systemName: "trash")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.red)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                }
                .padding()
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
            }
            .padding(.horizontal, 10)
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: 7, leading: 0, bottom: 7, trailing: 0))
            
            Button(action: onAdd) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.blue)
                        .font(.system(size: 20)) // Match other icons size
                    Text("Add \(title)")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.blue)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            /*
                            Color(red: 240/255, green: 242/255, blue: 250/255), // Slightly bluer tint
                            Color(red: 235/255, green: 237/255, blue: 245/255)
                            */
                            /*
                            Color(red: 240/255, green: 242/255, blue: 255/255), // More blue tint
                            Color(red: 235/255, green: 237/255, blue: 250/255)
                            */
                           
                            Color(red: 215/255, green: 220/255, blue: 255/255),  // Darker blue
                            Color(red: 200/255, green: 205/255, blue: 245/255)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.4), radius: 1, x: -2, y: 4)
            }
        } header: {
            Text(headerText)
                .font(.title2)
                .textCase(nil)  // This will override any inherited text transformation
                .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
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
