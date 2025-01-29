//
//  InfoPageView.swift
//  MyBudget
//
//  Created by Katya Durneva Svedmark on 2025-01-29.
//

import SwiftUI

struct InfoPageView: View {
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView {
            VStack {
                Text("MyBudgetBuddy")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top, 20)
                    .padding(.horizontal, 10)
                
                Text("Budgeting made easy, so you can focus on what matters most to you!")
                    .padding(.horizontal, 10)
                    .padding(.bottom, 20)
                
                // First section: Functionality
                VStack(alignment: .leading, spacing: 12) {
                    Text("How it works")
                        .font(.headline)
                        .padding(.horizontal, 10)
                    
                    Text("• Add your income and expenses, with expenses categorized as fixed or variable.")
                        .padding(.horizontal, 10)
                    Text("• Organize your finances better by adding your own categories, or stick with the default ones.")
                        .padding(.horizontal, 10)
                    Text("• Customize your own budget periods: choose from monthly, weekly, or even 5-day periods to match your needs.")
                        .padding(.horizontal, 10)
                    Text("• Keep track of your entire budget history, so you can see exactly where your money goes.")
                        .padding(.horizontal, 10)
                }
                
                // Second section: Upcoming features
                VStack(alignment: .leading, spacing: 12) {
                    Text("What’s coming next?")
                        .font(.headline)
                        .padding(.horizontal, 10)
                        .padding(.vertical)
                    
                    Text("• Get reminders when your budget period is nearing its end, so you’re always in control.")
                        .padding(.horizontal, 10)
                    Text("• Invoice reminders will soon be available to help you never miss a payment again!")
                        .padding(.horizontal, 10)
                }
                
                // Button to close or go back
                Button(action: {
                    dismiss()
                }) {
                    ButtonView(buttontext: "Close", expenseButton: true)
                }
                .padding(20)
            }
            .padding(.horizontal) // Apply horizontal padding to the content inside the ScrollView
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 245/255, green: 247/255, blue: 245/255), // Light gray
                        Color(red: 240/255, green: 242/255, blue: 240/255)  // Slightly darker gray
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
            .shadow(
                color: .black.opacity(0.35),
                radius: 8,
                x: 0,
                y: 6
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.4), lineWidth: 0.8)
            )
            .padding(.horizontal)
            .frame(maxWidth: .infinity)
        }
    }

}

#Preview {
    InfoPageView()
}
