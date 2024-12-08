//
//  IncomeModel.swift
//  MyBudget
//
//  Created by Katya Durneva Svedmark on 2024-12-07.
//

import Foundation

struct Income: Identifiable {
    let id = UUID()
    let amount: Double
    let category: String
}
