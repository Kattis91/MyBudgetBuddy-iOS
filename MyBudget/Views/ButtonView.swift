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
    var lightBackground: Bool = false
    
    var body: some View {
        
        Text(buttontext)
            .font(.headline)
            .padding(10)
            .frame(maxWidth: maxWidth)
            .frame(height: 45)
            .foregroundStyle(lightBackground ? Color.buttonsBackground : Color.white)
            .background(lightBackground ? Color.white : Color.buttonsBackground)
            .cornerRadius(12)
            .padding(.top, 10)
            .padding(.horizontal, 24)
    }
}

#Preview {
    ButtonView(buttontext: "Button", maxWidth: .infinity, lightBackground: false)
}
