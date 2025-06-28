//
//  RecipeModel.swift
//  MyQuickCook
//

import Foundation
import SwiftData

@Model
class RecipeModel: CustomStringConvertible {
    var id: String
    @Attribute(.unique) var name: String
    var image: String
    var ingredients: [String]
    var totalIngredients: Int
    var steps: [String]
    var totalSteps: Int
    var isLiked: Bool = false

    init( id: String, name: String, image: String, ingredients: [String], totalIngredients: Int, steps: [String], totalSteps: Int, isFavorite: Bool ) {
        self.id = id
        self.name = name
        self.image = image
        self.ingredients = ingredients
        self.totalIngredients = totalIngredients
        self.steps = steps
        self.totalSteps = totalSteps
        self.isLiked = isFavorite
    }

    var description: String {
        """
        🍽️ Recipe:
        - ID: \(id)
        - Name: \(name)
        - Image: \(image)
        - Ingredients: \(ingredients.joined(separator: ", "))
        - Total Ingredients: \(totalIngredients)
        - Steps: \(steps.joined(separator: " -> "))
        - Total Steps: \(totalSteps)
        - Is Favorite: \(isLiked)
        """
    }
}
