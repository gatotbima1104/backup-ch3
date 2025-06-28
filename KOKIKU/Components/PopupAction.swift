//
//  PopupAction.swift
//  MyQuickCook
//
//  Created by Muhamad Gatot Supiadin on 22/06/25.
//

import SwiftUI

struct PopupAction: View {
    var text: String
    
    var body: some View {
        Text(text)
            .font(.subheadline)
            .padding()
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(12)
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .padding(.top, 600)
    }
}
