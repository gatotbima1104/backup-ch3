//
//  InputViewModel.swift
//  MyQuickCook
//
//  Created by Muhamad Gatot Supiadin on 17/06/25.
//

import SwiftUI

class InputViewModel: ObservableObject {
    // States
    @Published var storages: [String] = ["Kulkas", "Freezer", "Rak Dapur"]
    @Published var ingredientInputs: [Ingredient]
    
    // computed data to check the forms filled or not
    var isFormValid: Bool {
        !ingredientInputs.contains{ $0.name.isEmpty || $0.storage.isEmpty}
    }
    
    // Init
    init() {
        let initial = Ingredient(id: UUID(), name: "", date: Date(), storage: "")
        self.ingredientInputs = [initial]
    }
    
    // init for pass data from camera input
    init(initialIngredients: [String]) {
        if initialIngredients.isEmpty {
            let initial = Ingredient(id: UUID(), name: "", date: Date(), storage: "")
            self.ingredientInputs = [initial]
        } else {
            self.ingredientInputs = initialIngredients.map { name in
                Ingredient(id: UUID(), name: name, date: Date(), storage: "")
            }
        }
    }

    // Add card
    func addCard() {
        let newIngredient = Ingredient(id: UUID(), name: "", date: Date(), storage: "")
        ingredientInputs.append(newIngredient)
    }
    
    // Remove card
    func popCard(_ id: UUID) {
        ingredientInputs.removeAll { $0.id == id }
    }
    
    // Binding value to change cards fields
    func binding(for id: UUID) -> Binding<Ingredient>? {
        guard let index = ingredientInputs.firstIndex(where: { $0.id == id }) else { return nil }
        return Binding(
            get: { self.ingredientInputs[index] },
            set: { self.ingredientInputs[index] = $0 }
        )
    }
    
    // Add from detected object
    func addIngredientsFromDetector(fromDetected detected: [String]) {
        for name in detected {
            let newIngredient = Ingredient(id: UUID(), name: name, date: Date(), storage: "")
            ingredientInputs.append(newIngredient)
        }
    }
}
