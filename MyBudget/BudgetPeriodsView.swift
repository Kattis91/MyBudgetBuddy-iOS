//
//  BudgetPeriodsView.swift
//  MyBudget
//
//  Created by Katya Durneva Svedmark on 2025-01-23.
//

import SwiftUI

struct PeriodListView: View {
    let periods: [BudgetPeriod]
    @State private var expandedPeriodID: UUID? = nil // Håller reda på expanderad period
    
    var body: some View {
        VStack {
            ForEach(periods) { period in
                PeriodRowView(
                    period: period,
                    isCurrent: false,
                    expandedPeriodID: $expandedPeriodID
                )
            }
        }
    }
}


#Preview {
   PeriodListView()
}
