//
//  NotificationManager.swift
//  MyQuickCook
//
//  Created by Wito Irawan on 21/06/25.
//

import Foundation
import UserNotifications
import SwiftData

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    func requestPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                completion(granted)
            }
            
            if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleNotification(for ingredient: IngredientModel) {
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "Peringatan Bahan: \(ingredient.storage)"
        content.body = ingredient.notificationMessage()
        content.sound = UNNotificationSound.default
        
        // Add ingredient ID as user info for deep linking
        content.userInfo = ["ingredientId": ingredient.id]
        
        // Create unique identifier for this notification
        let identifier = "ingredient-\(ingredient.id)"
        
        // Create trigger (daily check)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 86400, repeats: false) // 86400 seconds = 24 hours
        
        // Create request
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        // Add request to notification center
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleNotificationsForIngredients(_ ingredients: [IngredientModel]) {
        // Remove any existing scheduled notifications first
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        // Schedule new notifications for ingredients that need it
        for ingredient in ingredients.filter({ $0.shouldNotify() }) {
            scheduleNotification(for: ingredient)
        }
    }
    
    // Method to check ingredients and update notifications
    func checkAndUpdateNotifications(ingredients: [IngredientModel]) {
        // Filter ingredients that need notifications
        let ingredientsNeedingNotification = ingredients.filter { $0.shouldNotify() }
        
        // Schedule notifications for them
        scheduleNotificationsForIngredients(ingredientsNeedingNotification)
    }
}
