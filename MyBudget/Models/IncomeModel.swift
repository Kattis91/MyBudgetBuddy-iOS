//
//  IncomeModel.swift
//  MyBudget
//
//  Created by Katya Durneva Svedmark on 2024-12-07.
//

import Foundation

struct Income: Identifiable {
    let id: String
    let amount: Double
    let category: String
}

extension Income {
    func toDictionary() -> [String: Any] {
        return [
            "id": id,
            "amount": amount,
            "category": category
        ]
    }
}
