//
//  Recipe.swift
//  MyQuickCook
//
//  Created by JACKY HUANG WIJAYA on 17/06/25.
//

import Foundation
import UIKit

// Add new struct
struct IngredientDetail: Hashable, Codable {
    let name: String
    let quantity: String
}

struct Recipe: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let steps: [String]
    let totalSteps: Int
    let ingredients: [IngredientDetail]
    let totalIngredients: Int
    let isLiked: Bool
    
    
    // Check image in every used
    var image: String {
        let image_name = name.lowercased().replacingOccurrences(of: " ", with: "_")
        return UIImage(named: image_name) != nil ? image_name : "not_found"
    }
    
    init(name: String, steps: [String], ingredients: [IngredientDetail], isLiked: Bool) {
        self.name = name
        self.steps = steps
        self.totalSteps = steps.count
        self.ingredients = ingredients
        self.totalIngredients = ingredients.count
        self.isLiked = isLiked
    }
    
    func getRecipeByName(_ name: String) -> Recipe? {
        return self.name.lowercased() == name.lowercased() ? self : nil
    }
}
