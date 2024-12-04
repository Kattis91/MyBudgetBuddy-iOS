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
    
    var body: some View {
        Group {
            if isSecure {
                SecureField(placeholder, text: $text)
                    .frame(height: 45)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(.horizontal)
                    .background(Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.7), lineWidth: 0.5) // Border with rounded corners
                    )
                    .padding([.horizontal], 24)
                    .padding(.bottom, 3)
                    .onChange(of: text) {
                        onChange?()
                    }
            } else {
                TextField(placeholder, text: $text)
                    .frame(height: 45)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(.horizontal)
                    .background(Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.7), lineWidth: 0.5) // Border with rounded corners
                    )
                    .padding([.horizontal], 24)
                    .padding(.bottom, 3)
                    .onChange(of: text) {
                        onChange?()
                    }
            }
        }
    }
}

#Preview {
    @Previewable @State var email = ""
    @Previewable @State var password = ""
    CustomTextFieldView(placeholder: "Placeholder", text: $email, isSecure: false, onChange: {  })
}
