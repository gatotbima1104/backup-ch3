import Foundation
import SwiftUI

struct DisplayableIngredient: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let quantity: String
}

@MainActor
class RecipeDetailViewModel: ObservableObject {
    let storedRecipe: Recipe
    @Published private(set) var recipeName: String
    @Published private(set) var recipeImage: String
    @Published private(set) var steps: [String]
    @Published var isLiked: Bool
    
    @Published private(set) var ownedDisplayableIngredients: [DisplayableIngredient] = []
    @Published private(set) var missingDisplayableIngredients: [DisplayableIngredient] = []
    
    @Published private(set) var missingIngredientsCount: Int = 0
    @Published private(set) var totalStepCount: Int
    
    // ViewModel sekarang menerima 'recipe' DAN 'availableIngredients'
    init(recipe: Recipe, availableIngredients: [String]) {
        self.storedRecipe = recipe
        self.recipeName = recipe.name
        self.recipeImage = Self.imageFilename(recipe.name)
        self.steps = recipe.steps
        self.isLiked = recipe.isLiked
        self.totalStepCount = recipe.totalSteps

        let ownedSet = Set(availableIngredients.map { $0.lowercased().trimmingCharacters(in: .whitespaces) })

        var owned: [DisplayableIngredient] = []
        var missing: [DisplayableIngredient] = []

        for detail in recipe.ingredients {
            let name = detail.name.lowercased().trimmingCharacters(in: .whitespaces)
            let display = DisplayableIngredient(name: detail.name, quantity: detail.quantity)

            if ownedSet.contains(name) {
                owned.append(display)
            } else {
                missing.append(display)
            }
        }

        self.missingIngredientsCount = missing.count
        self.ownedDisplayableIngredients = owned.sorted { $0.name < $1.name }
        self.missingDisplayableIngredients = missing.sorted { $0.name < $1.name }
    }
    
    // capitalizename
    var capitalizedRecipeName: String {
        recipeName.prefix(1).capitalized + recipeName.dropFirst()
    }
    
    // MARK: - User Intents
    func toggleLikeStatus() {
        self.isLiked.toggle()
    }
    
    // MARK: - Private Helper
    private static func imageFilename(_ name: String) -> String {
        let formatted = name.lowercased().replacingOccurrences(of: " ", with: "_")
        // Fallback image jika gambar spesifik tidak ditemukan
        return UIImage(named: formatted) != nil ? formatted : "not_found"
    }
}
