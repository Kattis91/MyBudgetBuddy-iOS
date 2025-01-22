//
//  DateUtils.swift
//  MyBudget
//
//  Created by Katya Durneva Svedmark on 2025-01-22.
//

import Foundation

struct DateUtils {
    
    static func formattedDateRange(startDate: Date, endDate: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US") // För engelska månadsnamn
        formatter.dateFormat = "d MMM yyyy" // Visar dag, förkortad månad och år
        
        let startYear = Calendar.current.component(.year, from: startDate)
        let endYear = Calendar.current.component(.year, from: endDate)
        
        if startYear == endYear {
            // Samma år, visa endast året en gång
            formatter.dateFormat = "d MMM"
            let start = formatter.string(from: startDate)
            let end = formatter.string(from: endDate)
            return "\(start) - \(end) \(startYear)"
        } else {
            // Olika år, visa år för båda
            let start = formatter.string(from: startDate)
            let end = formatter.string(from: endDate)
            return "\(start) - \(end)"
        }
    }
}
