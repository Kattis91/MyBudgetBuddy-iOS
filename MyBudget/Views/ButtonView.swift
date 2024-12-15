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
    var greenBackground: Bool = false
    var height: CGFloat? = 45
    var leadingPadding: CGFloat = 24
    var trailingPadding: CGFloat = 24
    
    var body: some View {
        
        Text(buttontext)
            .font(.headline)
            .padding(10)
            .frame(maxWidth: maxWidth)
            .frame(height: height)
            .foregroundStyle(.white)
            .background(greenBackground ? Color.resetPasswordBox : Color.buttonsBackground)
            .cornerRadius(12)
            .padding(.top, 10)
            .padding(.leading, leadingPadding)
            .padding(.trailing, trailingPadding)
    }
}

#Preview {
    ButtonView(buttontext: "Button", maxWidth: .infinity, greenBackground: false)
}
