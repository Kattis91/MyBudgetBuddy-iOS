//
//  InvoiceModel.swift
//  MyBudget
//
//  Created by Katya Durneva Svedmark on 2025-02-01.
//

import Foundation

struct Invoice: Identifiable {
    let id: String
    let title: String
    let expiryDate: Date
}
