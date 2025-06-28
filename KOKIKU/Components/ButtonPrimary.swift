//
//  ButtonPrimary.swift
//  MyQuickCook
//
//  Created by Muhamad Gatot Supiadin on 22/06/25.
//

import SwiftUI

struct ButtonPrimary: View {
    var isDisabled: Bool
    var action: () -> Void
    var title: String

    var body: some View {
        Button(action: {
            action()
        }) {
            Text(title)
                .frame(maxWidth: .infinity)
                .font(.title3)
                .fontWeight(.bold)
                .padding()
                .background(
                    isDisabled ? Color.gray.opacity(0.5) : Color(hex: "006E6D")
                )
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .disabled(isDisabled)
    }
}
