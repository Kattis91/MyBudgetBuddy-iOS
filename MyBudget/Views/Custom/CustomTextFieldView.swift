//
//  CustomTextFieldView.swift
//  MyBudget
//
//  Created by Katya Durneva Svedmark on 2024-12-03.
//

import SwiftUI

struct CustomTextFieldView: View {
    
    var placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var onChange: (() -> Void)? = nil
    var leadingPadding: CGFloat = 24
    var trailingPadding: CGFloat = 24
    var systemName: String?
    var forget: Bool = false
    
    var body: some View {
        HStack {
            // Add the icon
            Image(systemName: systemName ?? "")
                .foregroundColor(Color.gray)
                .padding(.horizontal, 5)
                .scaledToFit()
                .frame(width: 20, height: 20)
            
            // Conditionally render SecureField or TextField
            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
            }
        }
        .frame(height: 50)
        .textFieldStyle(PlainTextFieldStyle())
        .padding(.horizontal)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [.backgroundTintLight, .backgroundTintDark]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 4)
        // Add subtle border for more definition
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.3), lineWidth: 0.5)
        )
        .padding(.leading, leadingPadding)
        .padding(.trailing, trailingPadding)
        .padding(.bottom, 6)
        .onChange(of: text) {
            onChange?()
        }
    }
}

#Preview {
    @Previewable @State var email = ""
    @Previewable @State var password = ""
    CustomTextFieldView(placeholder: "Placeholder", text: $email, isSecure: false, onChange: {  }, systemName: "envelope")
}
