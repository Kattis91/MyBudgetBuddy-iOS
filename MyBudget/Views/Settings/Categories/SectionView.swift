//
//  SectionView.swift
//  MyBudget
//
//  Created by Katya Durneva Svedmark on 2025-01-20.
//

import SwiftUI

struct SectionView: View {
    let categories: [String]
    let onEdit: (String) -> Void
    let onDelete: (String) -> Void
    let onAdd: () -> Void
    
    @Environment(\.colorScheme) var colorScheme
    var isDarkMode: Bool {
        return colorScheme == .dark
    }

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            VStack(alignment: .leading, spacing: 0) {
                // Categories List with Add Button
                List {
                    // Categories
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
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 7, leading: 20, bottom: 7, trailing: 20))
                        .listRowBackground(Color.clear)
                    }
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 15, leading: 24, bottom: 10, trailing: 24))
                    .listRowBackground(Color.clear)
                }
                .listStyle(PlainListStyle())
                .scrollContentBackground(.hidden)
            }
            
            // Floating action button
            Button(action: onAdd) {
                Image(systemName: "plus")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 56, height: 56)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: isDarkMode ?
                                [Color(red: 45/255, green: 50/255, blue: 60/255),
                                 Color(red: 32/255, green: 35/255, blue: 42/255)] :
                                [.buttonGradientLight, .buttonGradientDark]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
            }
            .padding(.leading, 20)
            .padding(.bottom, 20)
        }
    }
}


#Preview {
    SectionView(
        categories: ["A", "B", "C"],
        onEdit: { _ in },
        onDelete: { _ in },
        onAdd: { }
    )
}
