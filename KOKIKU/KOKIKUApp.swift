//
//  KOKIKUApp.swift
//  KOKIKU
//
//  Created by Muhamad Gatot Supiadin on 28/06/25.
//

import SwiftUI
import UserNotifications

@main
struct KOKIKUApp: App {
    @State private var showSplash = true
    
    //notification
    init() {
        // Set up the UNUserNotificationCenter delegate
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if showSplash {
                    SplashView()
                        .onAppear{
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                                withAnimation {
                                    showSplash = false
                                }
                            }
                        }
                } else {
                    ContentView()
                }
            }
//            ContentView()
        }
        .modelContainer(for: [IngredientModel.self, RecipeModel.self])  // inject modelcontainer
    }
}

// Notification delegate to handle notifications when app is in foreground
class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show the notification even when the app is in foreground
        if #available(iOS 14.0, *) {
            completionHandler([.banner, .sound, .badge])
        } else {
            completionHandler([.alert, .sound, .badge])
        }
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        // Handle notification tap
        let userInfo = response.notification.request.content.userInfo
        
        // Check if we have an ingredient ID
        if let ingredientId = userInfo["ingredientId"] as? String {
            // Store this ID to navigate to recipes when app is active
            UserDefaults.standard.set(ingredientId, forKey: "LatestNotificationIngredientId")
            NotificationCenter.default.post(name: Notification.Name("DidTapIngredientNotification"),
                                            object: nil,
                                            userInfo: ["ingredientId": ingredientId])
        }
        
        completionHandler()
    }
}
