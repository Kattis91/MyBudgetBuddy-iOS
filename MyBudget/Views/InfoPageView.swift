//
//  InfoPageView.swift
//  MyBudget
//
//  Created by Katya Durneva Svedmark on 2025-01-29.
//

import SwiftUI

struct InfoPageView: View {
    
    @Environment(\.dismiss) var dismiss

    let features: [(icon: String, title: String)] = [
        ("list.bullet.rectangle", "Add your income and expenses, with expenses categorized as fixed or variable."),
        ("square.grid.2x2", "Organize your finances better by adding your own categories, or stick with the default ones."),
        ("calendar.badge.clock", "Customize your own budget periods: choose from monthly, weekly, or even 5-day periods to match your needs."),
        ("chart.line.uptrend.xyaxis", "Keep track of your entire budget history, so you can see exactly where your money goes.")
    ]
    
    let extraFeatures: [(icon: String, title: String)] = [
        ("timer", "Get reminders when your budget period is nearing its end, so you’re always in control."),
        ("doc.text", "Invoice reminders will soon be available to help you never miss a payment again!")
    ]
    
    var body: some View {
        ScrollView {
            VStack {
                Text("MyBudgetBuddy")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top, 20)
                    .padding(.horizontal, 10)
                    .foregroundStyle(Color("PrimaryTextColor"))
                
                Text("Budgeting made easy, so you can focus on what matters most to you!")
                    .padding(.horizontal, 10)
                    .padding(.bottom, 20)
                    .foregroundStyle(Color("PrimaryTextColor"))
                
                // "How it works" Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("How it works")
                        .font(.headline)
                        .padding(.horizontal, 10)
                        .foregroundStyle(Color("PrimaryTextColor"))
                    
                    ForEach(features, id: \.title) { feature in
                        FeatureCardView(icon: feature.icon, text: feature.title)
                    }
                }
                .padding(.bottom, 20)
                .padding(.horizontal, 5)
                
                // "Extra Features" Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Extra Features")
                        .font(.headline)
                        .padding(.horizontal, 10)
                        .foregroundStyle(Color("PrimaryTextColor"))
                    
                    ForEach(extraFeatures, id: \.title) { feature in
                        FeatureCardView(icon: feature.icon, text: feature.title)
                    }
                }
                .padding(.horizontal, 5)
                
                // Close Button
                Button(action: {
                    dismiss()
                }) {
                    ButtonView(buttontext: "Close", expenseButton: true)
                }
                .padding(20)
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    InfoPageView()
}
