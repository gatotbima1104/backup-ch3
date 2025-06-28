//
//  DataManager.swift
//  MyQuickCook
//
//  Created by Muhamad Gatot Supiadin on 17/06/25.
//

import SwiftData
import Foundation

class DataManager {
    
    private var context: ModelContext
    
    // Init
    init(context: ModelContext) {
        self.context = context
    }
    
    func saveRecipe(from recipe: Recipe) {
            let normalizedName = recipe.name.trimmingCharacters(in: .whitespacesAndNewlines)

            let descriptor = FetchDescriptor<RecipeModel>(
                predicate: #Predicate { $0.name == normalizedName }
            )

            if let existing = try? context.fetch(descriptor).first {
                print("⚠️ Already exists: \(existing.name)")
                return
            }

            // Flatten IngredientDetail to string format (e.g., "2 cups flour")
            let flatIngredients: [String] = recipe.ingredients.map {
                $0.quantity.isEmpty ? $0.name : "\($0.quantity) \($0.name)"
            }

            let newRecipe = RecipeModel(
                id: UUID().uuidString,
                name: normalizedName,
                image: recipe.image,
                ingredients: flatIngredients,
                totalIngredients: flatIngredients.count,
                steps: recipe.steps,
                totalSteps: recipe.steps.count,
                isFavorite: true
            )

            context.insert(newRecipe)

            do {
                try context.save()
                print("✅ Saved Recipe: \(newRecipe.name)")
            } catch {
                print("❌ Failed to save recipe: \(error)")
            }
        }


    func removeRecipe(withName name: String) {
        let normalizedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        let descriptor = FetchDescriptor<RecipeModel>(
            predicate: #Predicate { $0.name == normalizedName }
        )

        do {
            if let recipe = try context.fetch(descriptor).first {
                context.delete(recipe)
                try context.save()
                print("🗑️ Deleted: \(normalizedName)")
            } else {
                print("⚠️ No recipe found to delete with name: \(normalizedName)")
            }
        } catch {
            print("❌ Delete error: \(error)")
        }
    }

    func printAllSavedRecipes() {
        let descriptor = FetchDescriptor<RecipeModel>()
        do {
            let recipes = try context.fetch(descriptor)
            print("📦 Total saved recipes: \(recipes.count)")
            for recipe in recipes {
                print("📄 \(recipe.name) (ID: \(recipe.id))")
            }
        } catch {
            print("❌ Error loading recipes: \(error)")
        }
    }


    // Save ingredients
    func saveIngredients(from list: [Ingredient]) {
        for item in list {
            let newIngredient = IngredientModel(
                id: item.id.uuidString, name: item.name, date: item.date, storage: item.storage
            )
            
            // insert to context
            context.insert(newIngredient)
        }
        
        do {
            // save the context
            try context.save()
            print("🍳 Saving \(list.count) items")
            print("✅ All ingredients saved to SwiftData")
        } catch {
            print("❌ Error saving ingredients: \(error.localizedDescription)")
        }
    }
    
    // remove ingredients
    func removeIngredients(with ids: [String], from ingredients: [IngredientModel], context: ModelContext) {
        for item in ingredients {
            if ids.contains(item.id) {
                context.delete(item)
            }
        }
        
        do {
            try context.save()
        } catch {
            print("Failed to save after deletion: \(error.localizedDescription)")
        }
    }
    
    // get list ingredients
    func getIngredients() -> [IngredientModel] {
        let descriptor = FetchDescriptor<IngredientModel>(
            sortBy: [SortDescriptor(\.date, order: .forward)]
        )
        
        do {
            return try context.fetch(descriptor)
        } catch {
            print("Failed to fetch ingredients: \(error.localizedDescription)")
            return []
        }
    }
}
