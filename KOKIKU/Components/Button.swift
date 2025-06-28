//
//  Button.swift
//  MyQuickCook
//
//  Created by Muhamad Gatot Supiadin on 14/06/25.
//

import SwiftUI

struct ButtonInfo: View {
    
    var labelText: String
    var onClick: () -> Void
    var backgroundColor: Color
    var iconName: String? = nil
    
    var body: some View {
        Button(action: {
            onClick()
        }){
            HStack {
                if let iconName = iconName {
                    Image(systemName: iconName)
                        .foregroundColor(.white)
                        .font(.title2)
                        .fontWeight(.bold)
                }
                
                Text(labelText)
                    .foregroundColor(.white)
                    .font(.headline)
            }
            .frame(width: 130, height: 50)
            .background(backgroundColor)
            .cornerRadius(8)
        }
    }
}
