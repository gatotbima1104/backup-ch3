//
//  FridgeView.swift
//  MyQuickCook
//
//  Created by Muhamad Gatot Supiadin on 16/06/25.
//

import SwiftUI
import SwiftData
import CoreHaptics
import UserNotifications

struct FridgeView: View {
    
    @StateObject var fridgeViewModel = FridgeViewModel() // Pull from FridgeViewModel
    @Query(sort: [SortDescriptor(\IngredientModel.date, order: .forward)]) private var ingredients: [IngredientModel]
    @Environment(\.modelContext) private var modelContext // Pull from swift data
    
    @State var resultRecommendation: [Recipe] = []
    @State private var dismissCameraToRoot = false
    @State private var hapticTrigger = false
    
    // Search computed
    private var filteredIngredients: [IngredientModel] {
        if fridgeViewModel.searchText.isEmpty {
            return ingredients
        } else {
            return ingredients.filter {
                $0.name.lowercased().contains(fridgeViewModel.searchText.lowercased())
            }
        }
    }
    
    @State private var navigateToRecommendation = false
    
    var body: some View {
        NavigationStack {
            mainContent
        }
    }
    
    // MARK: - Main Content
    @ViewBuilder
    private var mainContent: some View {
        VStack {
            Spacer()
            
            // Extract navigation links to keep them separate
            Group {
                // Hidden navigation link trigger for recommendation
                NavigationLink(isActive: $navigateToRecommendation) {
                    createRecommendationView()
                } label: {
                    EmptyView()
                }
                .hidden()
            }
            
            // Main content conditional
            if ingredients.isEmpty {
                FridgeEmptyView(fridgeViewModel: fridgeViewModel)
            } else {
                ingredientListView
            }
            
            Spacer()
        }
        // Apply common modifiers
        .navigationTitle("") // hide "back" in navigation
        .navigationBarTitleDisplayMode(.inline)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .safeAreaPadding(.all)
        
        // Add navigation destinations
        .navigationDestination(isPresented: $fridgeViewModel.isNavigateToFavorite) {
            createFavoriteView()
        }
        .navigationDestination(isPresented: $fridgeViewModel.isNavigateToInputText) {
            createInputTextView()
        }
        .navigationDestination(isPresented: $fridgeViewModel.isNavigateToInputCamera) {
            createInputImageView()
        }
        
        // Add sheet and overlay
        .sheet(isPresented: $fridgeViewModel.isPresented) {
            createInputOptionsView()
        }
        .overlay(createToastView(), alignment: .top)
        
        // Add notification handlers
        .onAppear {
            fridgeViewModel.checkNotificationPermissions()
            fridgeViewModel.updateNotifications(ingredients: ingredients)
        }
        .onChange(of: ingredients) { _, _ in
            fridgeViewModel.updateNotifications(ingredients: ingredients)
        }
    }
    
    // MARK: - View Builders
    // These functions create the views to avoid nesting them directly in modifiers
    private func createRecommendationView() -> some View {
        RecommendationRecipeView(
            isLoading: $fridgeViewModel.isLoading, cbResult: resultRecommendation,
            availableIngredients: fridgeViewModel.getSelectedIngredientNames(from: ingredients)
        )
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Rekomendasi")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(hex: "006E6D"))
            }
        }
    }
    
    private func createFavoriteView() -> some View {
        FavoriteView()
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Favorite Kamu")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(hex: "006E6D"))
                }
            }
    }
    
    private func createInputTextView() -> some View {
        InputTextView()
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Tambah Bahan")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(hex: "006E6D"))
                }
            }
    }
    
    private func createInputImageView() -> some View {
        InputImageView(dismissToRoot: $fridgeViewModel.isNavigateToInputCamera)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Tambah Bahan")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(hex: "006E6D"))
                }
            }
    }
    
    private func createInputOptionsView() -> some View {
        InputOptions(
            onSelectText: {
                fridgeViewModel.isPresented = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    fridgeViewModel.isNavigateToInputText = true
                }
            },
            onSelectCamera: {
                fridgeViewModel.isPresented = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    fridgeViewModel.isNavigateToInputCamera = true
                }
            }
        )
        .presentationDetents([.fraction(0.4)])
        .presentationDragIndicator(.visible)
    }
    
    @ViewBuilder
    private func createToastView() -> some View {
        if fridgeViewModel.showDeletedToast {
            PopupAction(text: "Bahan telah dihapus")
        }
    }
    
    // MARK: - Ingredient List View
    private var ingredientListView: some View {
        VStack(spacing: 16) {
            
//            Button {
//                let content = UNMutableNotificationContent()
//                content.title = "Hello, world!"
//                content.subtitle = "This is a test notification."
//                content.sound = UNNotificationSound.default
//                
//                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
//                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
//                
//                UNUserNotificationCenter.current().add(request)
//                
//                
//            } label: {
//                Text("Schedule notif")
//            }

            
            // Header
            HeaderView(
                searchText: $fridgeViewModel.searchText,
                isNavigateToFavorite: $fridgeViewModel.isNavigateToFavorite,
                isPresented: $fridgeViewModel.isPresented,
                showDeleteConfirmation: $fridgeViewModel.showDeleteConfirmation,
                selectedIngredientIDs: $fridgeViewModel.selectedIngredientIDs,
                deleteAction: {
                    fridgeViewModel.deleteSelectedIngredients(from: ingredients, context: modelContext)
                    hapticTrigger.toggle()
                }
            )
            .sensoryFeedback(.success, trigger: hapticTrigger)
            
            // Scrollable ingredient list
            ScrollView {
                ingredientCards
            }
            
            // Bottom section with button
            bottomActionSection
        }
    }
    
    // MARK: - Ingredient Cards
    private var ingredientCards: some View {
        LazyVStack(spacing: 16) {
            ForEach(filteredIngredients, id: \.id) { item in
                IngredientCardView(
                    ingredient: item,
                    selectedIngredients: $fridgeViewModel.selectedIngredientIDs
                )
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top)
    }
    
    // MARK: - Bottom Action Section
    private var bottomActionSection: some View {
        VStack(alignment: .leading) {
            // Selection information text
            let selectionText = !fridgeViewModel.selectedIngredientIDs.isEmpty
            ? "\(fridgeViewModel.selectedIngredientIDs.count) Bahan Terpilih"
            : "*Pilih bahan untuk mendapatkan rekomendasi"
            
            Text(selectionText)
                .font(.footnote)
                .multilineTextAlignment(.leading)
            
            // Search button
            ButtonPrimary(
                isDisabled: fridgeViewModel.selectedIngredientIDs.isEmpty,
                action: handleSearchButtonTap,
                title: "Cari Resep"
            )
        }
        .padding(.leading, 4)
        .multilineTextAlignment(.leading)
    }
    
    // MARK: - Action Handler
    private func handleSearchButtonTap() {
        fridgeViewModel.isLoading = true
        navigateToRecommendation = true
        
        Task {
            await fridgeViewModel.recommendFoods(using: ingredients)
            DispatchQueue.main.async {
                resultRecommendation = fridgeViewModel.cbResult
                fridgeViewModel.isLoading = false
            }
        }
    }
}

#Preview {
    let previewContainer = createPreviewContainer()
    
    return FridgeView()
        .modelContainer(previewContainer)
}

@MainActor private func createPreviewContainer() -> ModelContainer {
    let schema = Schema([IngredientModel.self])
    let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    
    do {
        let container = try ModelContainer(for: schema, configurations: [config])
        
        let dummyIngredients = [
            IngredientModel(id: UUID().uuidString, name: "ayam", date: .now, storage: "Kulkas"),
            IngredientModel(id: UUID().uuidString, name: "lele", date: .now, storage: "Kulkas"),
            IngredientModel(id: UUID().uuidString, name: "tempe", date: .now, storage: "Kulkas"),
            IngredientModel(id: UUID().uuidString, name: "tahu", date: .now, storage: "Kulkas"),
            IngredientModel(id: UUID().uuidString, name: "bawang putih", date: .now, storage: "Kulkas"),
            IngredientModel(id: UUID().uuidString, name: "Tomat", date: .now, storage: "Kulkas"),
        ]
        
        for item in dummyIngredients {
            container.mainContext.insert(item)
        }
        
        return container
    } catch {
        fatalError("Failed to create preview container: \(error)")
    }
}
