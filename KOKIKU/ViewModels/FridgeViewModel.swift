//
//  FridgeViewModel.swift
//  MyQuickCook
//
//  Created by Muhamad Gatot Supiadin on 16/06/25.
//

import SwiftUI
import SwiftData

class FridgeViewModel: ObservableObject {
    
    // States
    @Published var isPresented: Bool = false
    @Published var isNavigateToInputText: Bool = false
    @Published var isNavigateToInputCamera: Bool = false
    @Published var selectedIngredientIDs: [String] = []
    @Published var showDeleteConfirmation: Bool = false
    @Published var showDeletedToast: Bool = false
    //    @Published var cbResult: [(String, Double)] = []
    @Published var cbResult: [Recipe] = []
    @Published var isNavigateToRecommendationList: Bool = false
    @Published var searchText: String = ""
    @Published var isNavigateToFavorite: Bool = false
    
    // Notification
    @Published var notificationPermissionGranted: Bool = false
    
    //loading
    @Published var isLoading: Bool = false
    
    private var modelRecommender: FoodRecommenderContentBased!
    private let notifiedKey = "NotifiedIngredientIDs"
    
    // Load content based
    init() {
        let url = Bundle.main.url(forResource: "Food", withExtension: "csv")
        self.modelRecommender = try! FoodRecommenderContentBased(foodDataset: url!)
    }
    
    // get user default to prevent duplicate notif
    private var notifiedIngredientIDs: Set<String> {
        get {
            let ids = UserDefaults.standard.array(forKey: notifiedKey) as? [String] ?? []
            return Set(ids)
        }
        set {
            UserDefaults.standard.set(Array(newValue), forKey: notifiedKey)
        }
    }
    
    // delete selected ingredients
//    func deleteSelectedIngredients(from ingredients: [IngredientModel], context: ModelContext) {
//        let manager = DataManager(context: context)
//        manager.removeIngredients(
//            with: selectedIngredientIDs,
//            from: ingredients,
//            context: context
//        )
//        selectedIngredientIDs.removeAll()
//        
//        // Show the toast
//        withAnimation{
//            showDeletedToast = true
//        }
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//            withAnimation{
//                self.showDeletedToast = false
//            }
//        }
//    }
    
    // recommend food
    func recommendFoods(using ingredients: [IngredientModel]) {
        let selectedIngredientNames = ingredients
            .filter{ selectedIngredientIDs.contains($0.id) }
            .map{ $0.name }
        
        cbResult = modelRecommender.recommend(input: selectedIngredientNames)
//        print(cbResult)
        isNavigateToRecommendationList = true
    }
    
    // get names from selected ingredients
    func getSelectedIngredientNames(from ingredients: [IngredientModel]) -> [String] {
        ingredients
            .filter{ selectedIngredientIDs.contains($0.id) }
            .map(\.name)
    }
    
    //notification
    // Add this method to check for notification permissions
    func checkNotificationPermissions() {
        NotificationManager.shared.requestPermission { [weak self] granted in
            guard let self = self else { return }
            self.notificationPermissionGranted = granted
        }
    }
    
    // Add this method to update notifications based on ingredients
//    func updateNotifications(ingredients: [IngredientModel]) {
//        if notificationPermissionGranted {
//            NotificationManager.shared.checkAndUpdateNotifications(ingredients: ingredients)
//        }
//    }
    
    // Filter ingredients that need notification
    func updateNotifications(ingredients: [IngredientModel]) {
        let calendar = Calendar.current
        let now = Date()

        for ingredient in ingredients {
            let daysPassed = calendar.dateComponents([.day], from: ingredient.date, to: now).day ?? 0
            let adjustedDays = daysPassed + 1
            let idString = ingredient.id

            if adjustedDays >= 5 && !notifiedIngredientIDs.contains(idString) {
                let content = UNMutableNotificationContent()
                content.title = "Cek Bahanmu!"
                content.body = "Bahan \(ingredient.name) sudah \(adjustedDays) hari belum terpakai."
                content.sound = .default

                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
                let request = UNNotificationRequest(identifier: idString, content: content, trigger: trigger)

                UNUserNotificationCenter.current().add(request)
                notifiedIngredientIDs.insert(idString)
            }
        }
    }

    func deleteSelectedIngredients(from ingredients: [IngredientModel], context: ModelContext) {
        for ingredient in ingredients where selectedIngredientIDs.contains(ingredient.id) {
            context.delete(ingredient)
            notifiedIngredientIDs.remove(UUID().uuidString)
        }
        selectedIngredientIDs.removeAll()
        showDeletedToast = true
    }
}

