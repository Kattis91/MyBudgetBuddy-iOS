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
        .frame(height: 45)
        .textFieldStyle(PlainTextFieldStyle())
        .padding(.horizontal)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.7), lineWidth: 0.5) // Border with rounded corners
        )
        .padding(.leading, leadingPadding)
        .padding(.trailing, trailingPadding)
        .padding(.bottom, 3)
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
