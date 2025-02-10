//
//  FeatureCardView.swift
//  MyBudget
//
//  Created by Katya Durneva Svedmark on 2025-02-09.
//

import SwiftUI

struct FeatureCardView: View {
    let icon: String
    let text: String
    
    @Environment(\.colorScheme) var colorScheme
    var isDarkMode: Bool {
        return colorScheme == .dark
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(Color("ButtonsBackground"))
                .frame(width: 30, height: 30)
            
            Text(text)
                .font(.body)
                .multilineTextAlignment(.leading)
                .foregroundStyle(Color("PrimaryTextColor"))
        }
        .padding()
        .frame(maxWidth: .infinity) // Ensures all cards have the same width
        .background(
            LinearGradient(
                gradient: Gradient(colors: isDarkMode ?
                    [Color(.darkGray), Color(.black)] : // Dark Mode colors
                    [Color(red: 245/255, green: 247/255, blue: 245/255), Color(red: 240/255, green: 242/255, blue: 240/255)] // Light Mode colors
                ),
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(16)
        .shadow(
            color: .black.opacity(0.35),
            radius: 1,
            x: -2,
            y: 4
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.4), lineWidth: 0.8)
        )
    }
}

#Preview {
    FeatureCardView(icon: "timer", text: "Get reminders when your budget period is nearing its end, so you’re always in control.")
}
