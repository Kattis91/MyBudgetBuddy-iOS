//
//  InfoPageView.swift
//  MyBudget
//
//  Created by Katya Durneva Svedmark on 2025-01-29.
//

import SwiftUI

struct InfoPageView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @Environment(\.colorScheme) var colorScheme
    var isDarkMode: Bool {
        return colorScheme == .dark
    }
    
    @State private var selectedTab = 0

    let features: [(icon: String, title: String)] = [
        ("list.bullet.rectangle", String(localized: "Add your income and expenses, with expenses categorized as fixed or variable.")),
        ("square.grid.2x2", String(localized:"Organize your finances better by adding your own categories, or stick with the default ones.")),
        ("calendar.badge.clock", String(localized: "Customize your own budget periods: choose from monthly, weekly, or even 5-day periods to match your needs.")),
        ("chart.line.uptrend.xyaxis", String(localized: "Keep track of your entire budget history, so you can see exactly where your money goes."))
    ]
    
    let extraFeatures: [(icon: String, title: String)] = [
        ("timer", String(localized: "Stay in Control – Get timely reminders when your budget period is ending, so you can plan ahead with confidence.")),
        ("doc.text", String(localized:"Never Miss a Payment – Invoice reminders ensure you stay on track and stress-free when it comes to due dates."))
    ]
    
    let aboutTheDeveloper: [(icon: String, title: String)] = [("laptopcomputer", String(localized: "I’m Ekaterina Durneva Svedmark, the creator of this app and an aspiring app developer. This is my third project and my first independent app, built from concept to launch."))]
    
    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Spacer()
                    Text("MyBudgetBuddy")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.top, 20)
                        .padding(.horizontal, 10)
                        .foregroundStyle(Color("PrimaryTextColor"))
                    Spacer()
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(Color("ButtonsBackground"))
                    }
                }
                
                Text("Budgeting made easy, so you can focus on what matters most to you!")
                    .padding(.top, 5)
                    .padding(.horizontal, 10)
                    .foregroundStyle(Color("PrimaryTextColor"))
                
                Picker("Info", selection: $selectedTab) {
                    Text("About The App").tag(0)
                    Text("Development").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal, 7)
                .padding(.top, 20)
                
                switch selectedTab {
                case 0:
                    // "How it works" Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("How it works")
                            .font(.headline)
                            .padding(.horizontal, 10)
                            .padding(.top, 15)
                            .foregroundStyle(Color("PrimaryTextColor"))
                        
                        ForEach(features, id: \.title) { feature in
                            FeatureCardView(icon: feature.icon, text: feature.title)
                        }
                    }
                    .padding(.bottom, 20)
                    .padding(.horizontal, 5)
                    
                    // "Extra Features" Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Extra features")
                            .font(.headline)
                            .padding(.horizontal, 10)
                            .padding(.top, 15)
                            .foregroundStyle(Color("PrimaryTextColor"))
                        
                        ForEach(extraFeatures, id: \.title) { feature in
                            FeatureCardView(icon: feature.icon, text: feature.title)
                        }
                    }
                    .padding(.bottom, 20)
                    .padding(.horizontal, 5)
                    
                case 1:
                    VStack(alignment: .leading, spacing: 12) {
                        Text("The Developer")
                            .font(.headline)
                            .padding(.horizontal, 10)
                            .padding(.top, 15)
                            .foregroundStyle(Color("PrimaryTextColor"))
                        
                        ForEach(aboutTheDeveloper, id: \.title) { feature in
                            FeatureCardView(icon: feature.icon, text: feature.title)
                        }
                    }
                    .padding(.bottom, 20)
                    .padding(.horizontal, 5)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Credits")
                            .font(.headline)
                            .padding(.horizontal, 10)
                            .foregroundStyle(Color("PrimaryTextColor"))
                        
                        FeatureCardView(
                            icon: "star.fill",
                            attributedText: creditsText()
                        )
                    }
                    .padding(.bottom, 15)
                    .padding(.horizontal, 5)
                default:
                    EmptyView()
                }
                    
                // Close Button
                Button(action: {
                    dismiss()
                }) {
                    ButtonView(buttontext: "Close", expenseButton: true)
                }
                .padding(10)
            }
            .padding(.horizontal)
        }
    }
    
    func creditsText() -> AttributedString {
        var string = AttributedString(String(localized: "The icon used in the app is made by Stickers at "))
        var link = AttributedString("Flaticon.")
        link.link = URL(string: "https://www.flaticon.com")
        string.append(link)
        return string
    }
}

#Preview {
    InfoPageView()
}
