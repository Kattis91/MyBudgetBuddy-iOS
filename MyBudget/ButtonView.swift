//
//  ButtonView.swift
//  MyBudget
//
//  Created by Katya Durneva Svedmark on 2024-12-01.
//

import SwiftUI
struct ButtonView: View {
    
    var buttontext : String
    
    var body: some View {
       
        Text(buttontext)
            .font(.headline)
            .padding(10)
            .foregroundStyle(.white)
            .background(Color.blue)
            .cornerRadius(5)
            .padding(.top, 10)
        }
    }

#Preview {
    ButtonView(buttontext: "Button")
}
