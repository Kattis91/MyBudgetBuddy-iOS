//
//  CustomSettingsMenu.swift
//  MyBudget
//
//  Created by Katya Durneva Svedmark on 2025-01-10.
//

import SwiftUI

struct CustomSettingsMenu: View {
    @State private var showMenu = false
    @State private var showSettings = false
    @State var budgetfb: BudgetFB
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        showMenu.toggle()
                    }) {
                        Image(systemName: "gearshape")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding()
                            .background(Circle().fill(Color.purple))
                    }
                }
                Spacer()
            }
            .padding()

            if showMenu {
                VStack(alignment: .leading) {
                    Button(action: {
                        showSettings = true
                        showMenu = false
                    }) {
                        Text("Manage categories")
                            .padding()
                    }
                }
                .frame(width: 200)
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 5)
                .position(x: UIScreen.main.bounds.width - 120, y: 150)
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(budgetfb: budgetfb)
        }
    }
}

#Preview {
    CustomSettingsMenu(budgetfb: BudgetFB())
}
