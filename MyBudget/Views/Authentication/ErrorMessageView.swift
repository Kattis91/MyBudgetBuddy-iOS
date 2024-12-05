//
//  ErrorMessageView.swift
//  MyBudget
//
//  Created by Katya Durneva Svedmark on 2024-12-03.
//

import SwiftUI

struct ErrorMessageView: View {
    
    var errorMessage: String
    
    var body: some View {
        
        VStack(alignment: .leading) {
            HStack {
                Text(errorMessage)
                    .padding(.horizontal)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.leading)
                    .frame(height: 50) // Fixed height to reserve space
                    .opacity(errorMessage.isEmpty ? 0 : 1) // Fade out
                    .offset(x: errorMessage.isEmpty ? 20 : 0) // Slide to the right when disappearing
                    .animation(.easeInOut, value: errorMessage.isEmpty)
                Spacer()
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    ErrorMessageView(errorMessage: "Error")
}
