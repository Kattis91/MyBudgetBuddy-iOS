//
//  ExtensionColors.swift
//  MyBudget
//
//  Created by Katya Durneva Svedmark on 2024-12-20.
//

import Foundation
import SwiftUI

extension Color {
    // MARK: - Income Button Colors
    static let addIncomeStart = Color(red: 78 / 255, green: 177 / 255, blue: 181 / 255) // 76ADA1
    static let addIncomeMiddle = Color(red: 120 / 255, green: 182 / 255, blue: 168 / 255) // 78B6A8
    static let addIncomeEnd = Color(red: 57 / 255, green: 111 / 255, blue: 134 / 255) // BE607A
    
    // MARK: - Income Button Colors (Dark Mode)
    static let addIncomeStartDark = Color(red: 35/255, green: 85/255, blue: 88/255) // Very dark
    static let addIncomeMiddleDark = Color(red: 55/255, green: 90/255, blue: 82/255) // Very dark
    static let addIncomeEndDark = Color(red: 28/255, green: 50/255, blue: 65/255) // Very dark
    
    // MARK: - Expense Button Colors
    static let addExpenseStart = Color(red: 174 / 255, green: 41 / 255, blue: 114 / 255) // AE2972
    static let addExpenseMiddle = Color(red: 233 / 255, green: 93 / 255, blue: 115 / 255) // E95D73
    static let addExpenseEnd = Color(red: 201 / 255, green: 94 / 255, blue: 123 / 255) // C95E7B
    
    // MARK: - Expense Button Colors (Dark Mode)
    static let addExpenseStartDark = Color(red: 120/255, green: 30/255, blue: 80/255) // Darker version of addExpenseStart
    static let addExpenseMiddleDark = Color(red: 160/255, green: 65/255, blue: 80/255) // Darker version of addExpenseMiddle
    static let addExpenseEndDark = Color(red: 140/255, green: 65/255, blue: 85/255) // Darker version of addExpenseEnd
    
    // MARK: - Background Colors
    static let backgroundTint = Color(red: 245 / 255, green: 247 / 255, blue: 245 / 255) // F5F7F5
    static let cardShadow = Color.black.opacity(0.05)
  
    // MARK: - Statistic Box Colors
    static let backgroundTintLight = Color(red: 252/255, green: 242/255, blue: 230/255)  // Darker warm tone
    static let backgroundTintDark = Color(red: 245/255, green: 235/255, blue: 220/255)
    
    static let darkGradientStart = Color(red: 40/255, green: 40/255, blue: 45/255)
    static let darkGradientEnd = Color(red: 28/255, green: 28/255, blue: 32/255)
    
    static let inputGradientLight = Color(red: 102/255, green: 102/255, blue: 104/255)  // #666668
    static let inputGradientDark = Color(red: 92/255, green: 92/255, blue: 94/255)      // #5C5C5E
    
    // MARK: - Button Colors
    static let buttonGradientLight = Color(red: 190/255, green: 195/255, blue: 255/255)  // More saturated blue
    static let buttonGradientDark = Color(red: 170/255, green: 175/255, blue: 240/255)
}
