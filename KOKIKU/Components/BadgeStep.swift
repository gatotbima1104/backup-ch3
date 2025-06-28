//
//  BadgeStep.swift
//  MyQuickCook
//
//  Created by Muhamad Gatot Supiadin on 24/06/25.
//

import SwiftUI

struct BadgeStep: View {
    
    var text: String
    var size: CGFloat?
    
    var body: some View {
        HStack {
            Text(text)
                .frame(maxWidth: size)
                .foregroundColor(.white)
                .font(.caption)
                .fontWeight(.bold)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Color(hex: "006E6D")
                        .cornerRadius(4)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        }
    }
}
