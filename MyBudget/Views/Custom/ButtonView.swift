//
//  ButtonView.swift
//  MyBudget
//
//  Created by Katya Durneva Svedmark on 2024-12-01.
//

import SwiftUI
struct ButtonView: View {
    
    var buttontext : String
    var maxWidth: CGFloat? = .infinity
    var incomeButton: Bool = false
    var expenseButton: Bool = false
    var height: CGFloat? = 45
    var leadingPadding: CGFloat = 24
    var trailingPadding: CGFloat = 24
    var topPadding: CGFloat = 10
    
    @Environment(\.colorScheme) var colorScheme
    var isDarkMode: Bool {
        return colorScheme == .dark
    }
    
    var body: some View {
        
        Text(buttontext)
            .font(.headline)
            .padding(10)
            .frame(maxWidth: maxWidth)
            .frame(height: height)
            .foregroundStyle(.white)
            .background(
                expenseButton ?
                    LinearGradient(
                      gradient: Gradient(colors: [
                        isDarkMode ? .addExpenseStartDark : .addExpenseStart,
                        isDarkMode ? .addExpenseMiddleDark : .addExpenseMiddle,
                        isDarkMode ? .addExpenseEndDark : .addExpenseEnd
                      ]),
                      startPoint: .topLeading,
                      endPoint: .bottomTrailing
                    ) :
                incomeButton ?
                  LinearGradient(
                      gradient: Gradient(colors: [
                        isDarkMode ? .addIncomeStartDark : .addIncomeStart,   // Start color
                        isDarkMode ? .addIncomeMiddleDark : .addIncomeMiddle,  // Middle color
                        isDarkMode ? .addIncomeEndDark : .addIncomeEnd     // End color
                      ]),
                      startPoint: .topLeading,
                      endPoint: .bottomTrailing
                  ) :
                    LinearGradient(
                    gradient: Gradient(colors: [
                        .buttonGradientLight,
                        .buttonGradientDark// End color
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(12)
            .padding(.top, topPadding)
            .padding(.leading, leadingPadding)
            .padding(.trailing, trailingPadding)
    }
}

#Preview {
    ButtonView(buttontext: "Button", maxWidth: .infinity, incomeButton: false)
}
