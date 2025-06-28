//
//  FoodRecommenderContentBased.swift
//  MyQuickCook
//
//  Created by Muhamad Gatot Supiadin on 11/06/25.
//

import Foundation
import SwiftCSV //import swiftCSV from third party library

struct FoodRecommenderContentBased {
    
    // Variables
    private let foodVectors: [Int: [Double]]
    private let ingredientIndex: [String: Int]
    private let fullRecipes: [Int: Recipe]

    init(foodDataset url: URL) throws {
        let csv = try CSV<Named>(url: url)
        
        var ingredientsSet = Set<String>()
        var rawData = [(id: Int, name: String, ingredients: [IngredientDetail], steps: [String], totalSteps: Int)]()
        var fullRecipesMap = [Int: Recipe]()

        for row in csv.rows {
            guard
                let id = Int(row["foodId"] ?? ""),
                let name = row["Title"],
                let ingredientsRaw = row["Ingredients"],
                let stepsRaw = row["Steps"],
                let totalSteps = Int(row["Total_Steps"] ?? "")
            else {
                continue
            }

//            print("📄 Parsing row ID \(id) - \(name)")
//            print("🧾 Raw Ingredients: \(ingredientsRaw)")

            // Use regex to extract pairs: ("name", "quantity")
            let pattern = #"\"([^\"]+)\"[, ]+\"([^\"]+)\""#
            let regex = try? NSRegularExpression(pattern: pattern, options: [])

            var ingredientDetails: [IngredientDetail] = []

            if let regex = regex {
                let matches = regex.matches(in: ingredientsRaw, options: [], range: NSRange(ingredientsRaw.startIndex..., in: ingredientsRaw))

                for match in matches {
                    if let nameRange = Range(match.range(at: 1), in: ingredientsRaw),
                       let quantityRange = Range(match.range(at: 2), in: ingredientsRaw) {
                        let name = String(ingredientsRaw[nameRange]).lowercased()
                        let quantity = String(ingredientsRaw[quantityRange])
                        ingredientDetails.append(IngredientDetail(name: name, quantity: quantity))
                        ingredientsSet.insert(name)
                    }
                }
            }
//            print("🧪 Parsed ingredients: \(ingredientDetails.map { "\($0.quantity) \($0.name)" })")

            let steps = stepsRaw
                .components(separatedBy: "\n")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }

            rawData.append((id, name, ingredientDetails, steps, totalSteps))

            let recipe = Recipe(
                name: name,
                steps: steps,
                ingredients: ingredientDetails,
                isLiked: false
            )
            fullRecipesMap[id] = recipe
        }

        let allIngredients = Array(ingredientsSet).sorted()
        let index = Dictionary(uniqueKeysWithValues: allIngredients.enumerated().map { ($1, $0) })

        var vectors = [Int: [Double]]()
        for entry in rawData {
            var vec = Array(repeating: 0.0, count: allIngredients.count)
            for detail in entry.ingredients {
                if let idx = index[detail.name] {
                    vec[idx] = 1.0
                }
            }
            vectors[entry.id] = vec
        }

        self.ingredientIndex = index
        self.foodVectors = vectors
        self.fullRecipes = fullRecipesMap
//        print("📦 Indexed ingredients count: \(ingredientIndex.count)")
    }

    func recommend(input ingredients: [String], topN: Int = 5) -> [Recipe] {
        var inputVec = Array(repeating: 0.0, count: ingredientIndex.count)

        let inputTrimmed = ingredients.map {
            $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        }

        var unmatchedIngredients: [String] = []

        for ingredient in inputTrimmed {
            if let idx = ingredientIndex[ingredient] {
                inputVec[idx] = 1.0
            } else {
                unmatchedIngredients.append(ingredient)
            }
        }

        if !unmatchedIngredients.isEmpty {
//            print("❌ Unmatched input ingredients (not found in dataset): \(unmatchedIngredients)")
        }

        let tNormalization = sqrt(inputVec.map { $0 * $0 }.reduce(0, +))
        guard tNormalization > 0 else {
//            print("❌ Input vector is zero. No valid ingredients found. Recommendation aborted.")
            return []
        }

        var scored = [(id: Int, score: Double)]()

        for (id, vec) in foodVectors {
            let dot = zip(inputVec, vec).map(*).reduce(0, +)
            let vNorm = sqrt(vec.map { $0 * $0 }.reduce(0, +))
            guard vNorm > 0 else { continue }

            let similarity = dot / (tNormalization * vNorm)
            scored.append((id, similarity))
        }

        let sorted = scored.sorted { $0.score > $1.score }
        return sorted.prefix(topN).compactMap { fullRecipes[$0.id] }
    }
}

