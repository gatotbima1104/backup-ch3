//
//  IngredientModel.swift
//  MyQuickCook
//
//  Created by Muhamad Gatot Supiadin on 17/06/25.
//

import Foundation

struct Ingredient: Identifiable, Equatable, Hashable {
    let id: UUID
    var name: String
    var date: Date
    var storage: String
    
    init(id: UUID = UUID(), name: String, date: Date, storage: String) {
        self.id = id
        self.name = name
        self.date = date
        self.storage = storage
    }
    
    // Convenience initializer that accepts string date
    init(id: UUID = UUID(), name: String, dateString: String, storage: String) {
        self.id = id
        self.name = name
        
        // Convert string date to Date object
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        self.date = dateFormatter.date(from: dateString) ?? Date()
        
        self.storage = storage
    }
    
    // Calculate days since the ingredient was stored
    func daysSinceStored() -> Int {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.day], from: date, to: now)
        return components.day ?? 0
    }
    
    // Get threshold based on storage type
    func notificationThreshold() -> Int {
        switch storage.lowercased() {
        case "freezer":
            return 8  // Show notification after 8 days in freezer
        case "refrigerator":
            return 5  // Show notification after 5 days in refrigerator
        case "room":
            return 3  // Show notification after 3 days at room temperature
        default:
            return 5  // Default to 5 days for unknown storage types
        }
    }
    
    // Check if notification should be shown based on storage-specific thresholds
    func shouldNotify() -> Bool {
        return daysSinceStored() >= notificationThreshold()
    }
    
    // Get the notification message
    func notificationMessage() -> String {
        return "Your \(name) already \(daysSinceStored()) days in the \(storage), tap to find best recipe to cook"
    }
    
    // Get days remaining before notification
    func daysRemaining() -> Int {
        let threshold = notificationThreshold()
        let daysPassed = daysSinceStored()
        let remaining = threshold - daysPassed
        return remaining > 0 ? remaining : 0
    }
}
