//
//  RecipeCard.swift
//  MyQuickCook
//
//  Created by JACKY HUANG WIJAYA on 17/06/25.
//

import SwiftUI

struct RecipeCard: View {
    let recipe: Recipe
    let availableIngredients: [String]
    
    var body: some View {
        
        let missingCount = missingIngredients.count
        let isComplete = missingCount == 0
        
        HStack {
            Image(recipe.image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 100, height: 100)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(alignment: .leading, spacing: 8) {
                Text(recipe.name.prefix(1).capitalized + recipe.name.dropFirst())
                    .font(.headline)
                    .foregroundStyle(Color(hex: "006E6D"))
                HStack (spacing: 4) {
                    Text(isComplete ? "Lengkap" : "Kurang \(missingCount) Bahan")
                            .foregroundColor(.white)
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 4)
                            .background(
                                Color(hex: "006E6D")
                                    .cornerRadius(4)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                    Text("\(recipe.totalSteps) Langkah")
                            .foregroundColor(.white)
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .padding(.horizontal, 4)
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
                // informasi missing ingredients
                if !missingIngredients.isEmpty {
                    Text("Ups! Bahan kamu kurang: \(missingIngredients.joined(separator: ", "))")
                        .foregroundColor(.black)
                        .font(.subheadline)
                        .lineLimit(2)
                        .truncationMode(.tail)
                        .multilineTextAlignment(.leading)
                } else {
                    Text("Kamu sudah punya semua yang dibutuhkan. Ayo mulai memasak!")
                        .foregroundColor(.black)
                        .font(.subheadline)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
        .shadow(radius: 2)
    }
    
    // get missing ingredients
//    private var missingIngredients: [String] {
//        let available = Set(availableIngredients.map { $0.lowercased().trimmingCharacters(in: .whitespaces) })
//        return recipe.ingredients.filter { !available.contains($0.lowercased().trimmingCharacters(in: .whitespaces)) }
//    }
    
    private var missingIngredients: [String] {
        let available = Set(availableIngredients.map { $0.lowercased().trimmingCharacters(in: .whitespaces) })
        return recipe.ingredients
            .map { $0.name }
            .filter { !available.contains($0.lowercased().trimmingCharacters(in: .whitespaces)) }
    }
}
