//
//  NotificationBannerView.swift
//  MyQuickCook
//
//  Created by Wito Irawan on 21/06/25.
//

import SwiftUI

struct IngredientNotificationBanner: View {
    let ingredient: IngredientModel
    var onTapRecipe: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                Text("Peringatan Bahan")
                    .font(.headline)
                Spacer()
                
                // Show notification threshold info
                Text("\(ingredient.storage): \(ingredient.notificationThreshold()) hari")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(ingredient.notificationMessage())
                .font(.subheadline)
            
            Button(action: onTapRecipe) {
                Text("Cari Resep")
                    .fontWeight(.medium)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(Color(hex: "006E6D"))
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
        .padding(.horizontal, 8)
    }
}
