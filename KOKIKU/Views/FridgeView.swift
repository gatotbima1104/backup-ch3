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
                    // Aksesibilitas untuk tampilan kosong
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Kulkas Anda kosong.")
                    .accessibilityHint("Ketuk tombol tambah untuk menambahkan bahan baru.")
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
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityLabel("Hasil Rekomendasi")
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
                        .accessibilityAddTraits(.isHeader)
                        .accessibilityLabel("Favorit Kamu")
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
                        .accessibilityAddTraits(.isHeader)
                        .accessibilityLabel("Tambah Bahan")
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
                        .accessibilityAddTraits(.isHeader)
                        .accessibilityLabel("Tambah Bahan")
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
        .accessibilityLabel("Pilihan Input")
        .accessibilityHint("Pilih untuk menambahkan bahan melalui teks atau kamera.")
    }
    
    @ViewBuilder
    private func createToastView() -> some View {
        if fridgeViewModel.showDeletedToast {
            PopupAction(text: "Bahan telah dihapus")
                .accessibilityLabel("Bahan telah dihapus")
                .accessibilityHint("Memberitahukan bahwa bahan yang dipilih telah dihapus.")
        }
    }
    
    // MARK: - Ingredient List View
    private var ingredientListView: some View {
        VStack(spacing: 16) {
            
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
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Kontrol Kulkas")
            .accessibilityHint("Berisi pilihan pencarian, favorit, tambah, dan hapus.")

            
            // Scrollable ingredient list
            ScrollView {
                ingredientCards
            }
            .accessibilityLabel("Daftar bahan-bahan Anda")
            
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
                .accessibilityElement(children: .combine)
                .accessibilityLabel("\(item.name), disimpan di \(item.storage).")
                .accessibilityValue(fridgeViewModel.selectedIngredientIDs.contains(item.id) ? "Terpilih" : "Tidak terpilih")
                .accessibilityHint("Ketuk dua kali untuk memilih atau batal memilih.")
                .accessibilityAddTraits(.isButton)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top)
    }
    
    // MARK: - Bottom Action Section
    private var bottomActionSection: some View {
        VStack(alignment: .leading) {
            // Teks informasi pilihan
            let selectionText = !fridgeViewModel.selectedIngredientIDs.isEmpty
            ? "\(fridgeViewModel.selectedIngredientIDs.count) Bahan Terpilih"
            : "*Pilih bahan untuk mendapatkan rekomendasi"
            
            Text(selectionText)
                .font(.footnote)
                .multilineTextAlignment(.leading)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Ringkasan Pilihan")
                .accessibilityValue(selectionText)
            
            // Tombol Cari
            ButtonPrimary(
                isDisabled: fridgeViewModel.selectedIngredientIDs.isEmpty,
                action: handleSearchButtonTap,
                title: "Cari Resep"
            )
            .accessibilityLabel("Cari Resep")
            .accessibilityValue(fridgeViewModel.selectedIngredientIDs.isEmpty ? "Nonaktif" : "Aktif")
            .accessibilityHint(fridgeViewModel.selectedIngredientIDs.isEmpty ? "Pilih satu atau lebih bahan untuk mengaktifkan tombol ini." : "Mencari resep berdasarkan bahan yang Anda pilih.")
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
