//
//  FavoriteView.swift
//  MyQuickCook
//
//  Created by Muhamad Gatot Supiadin on 21/06/25.
//

import SwiftUI
import SwiftData

struct FavoriteView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Query private var ingredients: [IngredientModel]

    var availableIngredients: [String] {
        ingredients.map { $0.name }
    }
    @State private var selectedRecipe: Recipe?
    @State private var favoriteRecipes: [RecipeModel] = []
    
    
    var body: some View {
        
        VStack (spacing: 16) {
            if !favoriteRecipes.isEmpty {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(favoriteRecipes) { recipeModel in
                            // Convert RecipeModel to Recipe
                            let recipe = Recipe(
                                name: recipeModel.name,
                                steps: recipeModel.steps,
                                ingredients: recipeModel.ingredients.map {
                                    let components = $0.split(separator: " ", maxSplits: 2, omittingEmptySubsequences: true)
                                    if components.count >= 2 {
                                        let quantity = "\(components[0]) \(components[1])"
                                        let name = components.dropFirst(2).joined(separator: " ")
                                        return IngredientDetail(name: name, quantity: quantity)
                                    } else {
                                        return IngredientDetail(name: $0, quantity: "")
                                    }
                                },
                                isLiked: recipeModel.isLiked
                            )
                            RecipeCardFavorite(recipe: recipe, availableIngredients: availableIngredients)
                                .padding(.top, 2)
                                .padding(.horizontal, 2)
                                .onTapGesture {
                                    selectedRecipe = recipe
                                }
                                .accessibilityElement(children: .combine)
                                .accessibilityLabel("Resep Favorit: \(recipe.name)")
                                .accessibilityHint("Ketuk dua kali untuk melihat detail resep.")
                                .accessibilityAddTraits(.isButton)
                        }
                    }
                }
                .scrollIndicators(.hidden)
                .accessibilityLabel("Daftar resep favorit Anda")
            } else {
                VStack {
                    Image("mascot")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .accessibilityLabel("Maskot KOKIKU")
                    
                    VStack(spacing: 32) {
                        Text("Kamu belum punya menu favorite")
                            .font(.title2)
                            .foregroundStyle(Color(hex: "006E6D"))
                            .multilineTextAlignment(.center)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                            .frame(maxWidth: 350)
                            .accessibilityElement(children: .combine)
                            .accessibilityLabel("Kamu belum punya menu favorit. Silakan cari resep dan tambahkan ke favorit.")

                        // Button
                        Button(action: {
                            // back to fridge view
                            dismiss()
                        }){
                            HStack {
                                Text("Lihat Bahan")
                                    .foregroundColor(.white)
                                    .font(.title3)
                                    .fontWeight(.bold)
                            }
                            .frame(width: 200, height: 50)
                            .background(Color(hex: "006E6D"))
                            .cornerRadius(8)
                        }
                        .accessibilityLabel("Lihat Bahan")
                        .accessibilityHint("Kembali ke halaman kulkas untuk mencari resep baru.")
                    }
                }
            }
        }
        .padding()
        .navigationDestination(item: $selectedRecipe) { recipe in
                    RecipeDetailView(recipe: recipe, availableIngredients: availableIngredients)
        }
        .onAppear {
            fetchFavorites()
        }
    }
    
    func fetchFavorites() {
        let descriptor = FetchDescriptor<RecipeModel>(
            predicate: #Predicate { $0.isLiked == true }
        )
        do {
            favoriteRecipes = try context.fetch(descriptor)
            print("📦 Total favorites: \(favoriteRecipes.count)")
        } catch {
            print("❌ Error fetching favorites: \(error)")
        }
    }
}

#Preview {
    FavoriteView()
}
