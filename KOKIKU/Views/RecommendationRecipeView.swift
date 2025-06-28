//
//  RecommendationRecipeView.swift
//  MyQuickCook
//
//  Created by JACKY HUANG WIJAYA on 17/06/25.
//

import SwiftUI

struct RecommendationRecipeView: View {
//    @StateObject private var viewModel = RecommendationRecipeViewModel()
    @State private var selectedRecipe: Recipe?
    @Binding var isLoading: Bool
    
    let cbResult: [Recipe]
    let availableIngredients: [String]
    
    // Add this initializer
    init(isLoading: Binding<Bool>, cbResult: [Recipe], availableIngredients: [String]) {
        self._isLoading = isLoading
        self.cbResult = cbResult
        self.availableIngredients = availableIngredients
    }
    
    var body: some View {
        VStack(spacing: 16) {
            if isLoading {
                loadingView
            }
            else if cbResult.isEmpty {
                VStack {
                    Image("mascot")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                    Text("Rekomendasi masih kosong")
                        .font(.title2)
                        .foregroundStyle(Color(hex: "006E6D"))
                        .multilineTextAlignment(.center)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                        .frame(maxWidth: 350)
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(Array(cbResult.enumerated()), id: \.offset) { index, recipe in
                            RecipeCard(recipe: recipe, availableIngredients: availableIngredients)
                                .padding(.top, 2)
                                .padding(.horizontal, 2)
                                .onTapGesture {
                                    selectedRecipe = recipe
                                }
                        }
                    }
                }
                .scrollIndicators(.hidden)
            }
        }
        .padding()
        .navigationTitle("") // Set judul menjadi string kosong
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(item: $selectedRecipe) { recipe in
                    RecipeDetailView(recipe: recipe, availableIngredients: availableIngredients)
                }
    }
    
    // MARK: - Loading View with Skeleton Animation
    private var loadingView: some View {
        VStack(spacing: 20) {
            // Skeleton recipe cards
//            Text("Memuat Rekomendasi Resep...")
            ScrollView {
                LazyVStack(spacing: 20) {
                    ForEach(0..<5, id: \.self) { _ in
                        SkeletonRecipeCardView()
                    }
                }
            }
        }
    }
    
}

// MARK: - Skeleton Recipe Card View
struct SkeletonRecipeCardView: View {
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Left side: Image skeleton
            Rectangle()
                .fill(LinearGradient(
                    gradient: Gradient(colors: [Color.gray.opacity(0.35), Color.gray.opacity(0.25), Color.gray.opacity(0.35)]),
                    startPoint: .leading,
                    endPoint: .trailing
                ))
                .frame(width: 120, height: 120)
                .cornerRadius(8)
                .shimmer()
            
            // Right side: Content skeleton
            VStack(alignment: .leading, spacing: 10) {
                // Title skeleton
                Rectangle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [Color.gray.opacity(0.35), Color.gray.opacity(0.25), Color.gray.opacity(0.35)]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
                    .frame(height: 24)
                    .cornerRadius(4)
                    .shimmer()
                
                // Pills row skeleton
                HStack(spacing: 8) {
                    Rectangle()
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [Color.gray.opacity(0.35), Color.gray.opacity(0.25), Color.gray.opacity(0.35)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                        .frame(width: 100, height: 30)
                        .cornerRadius(15)
                        .shimmer()
                    
                    Rectangle()
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [Color.gray.opacity(0.35), Color.gray.opacity(0.25), Color.gray.opacity(0.35)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                        .frame(width: 80, height: 30)
                        .cornerRadius(15)
                        .shimmer()
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Rectangle()
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [Color.gray.opacity(0.35), Color.gray.opacity(0.25), Color.gray.opacity(0.35)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                        .frame(height: 14)
                        .cornerRadius(4)
                        .shimmer()
                    
                    Rectangle()
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [Color.gray.opacity(0.35), Color.gray.opacity(0.25), Color.gray.opacity(0.35)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                        .frame(width: 130, height: 14)
                        .cornerRadius(4)
                        .shimmer()
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6)) // Slightly gray background for contrast
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.08), radius: 5, x: 0, y: 2)
    }
}


// MARK: - Shimmer Effect Modifier
struct ShimmerEffect: ViewModifier {
    @State private var isAnimating = false
    
    func body(content: Content) -> some View {
        content
            .overlay(
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.clear,
                                Color.white.opacity(0.5),
                                Color.clear
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .offset(x: isAnimating ? 400 : -400)
                    .onAppear {
                        withAnimation(
                            Animation.linear(duration: 1.5)
                                .repeatForever(autoreverses: false)
                        ) {
                            isAnimating = true
                        }
                    }
            )
            .mask(content)
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerEffect())
    }
}
