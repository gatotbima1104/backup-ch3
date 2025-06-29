import SwiftUI
import SwiftData

struct RecipeDetailView: View {
    @StateObject private var viewModel: RecipeDetailViewModel
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    init(recipe: Recipe, availableIngredients: [String]) {
        _viewModel = StateObject(wrappedValue: RecipeDetailViewModel(recipe: recipe, availableIngredients: availableIngredients))
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            
            ZStack(alignment: .topLeading) {
                
                Image(viewModel.recipeImage)
                    .resizable()
                    .scaledToFill()
                    .frame(maxHeight: 350, alignment: .center)
                    .clipped()
                    .accessibilityLabel("Gambar masakan \(viewModel.capitalizedRecipeName)")
            
                VStack(alignment: .leading, spacing: 24) {
                    
                    // Header
                    HStack {
                        Text(viewModel.capitalizedRecipeName)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(Color(hex: "006E6D"))
                            .accessibilityAddTraits(.isHeader)
                        
                        Spacer()
                        
                        Button {
                            let manager = DataManager(context: modelContext)
                            
                            manager.printAllSavedRecipes()
                            
                            if viewModel.isLiked {
                                    manager.removeRecipe(withName: viewModel.recipeName)
                                manager.printAllSavedRecipes()
                                } else {
                                    manager.saveRecipe(from: viewModel.storedRecipe)
                                    manager.printAllSavedRecipes()
                                }
                            
                            viewModel.isLiked.toggle()
                            
                        } label: {
                            Image(systemName: viewModel.isLiked ? "heart.fill" : "heart")
                                .foregroundColor(Color(hex: "006E6D"))
                                .font(.title)
                        }
                        .accessibilityLabel("Tombol Favorit")
                        .accessibilityValue(viewModel.isLiked ? "Disukai" : "Tidak disukai")
                        .accessibilityHint("Ketuk dua kali untuk menambah atau menghapus resep dari favorit.")
                    }
                    
                    // Info Box
                    HStack(spacing: 10) {
                        Badge(text: "Kurang \(viewModel.missingIngredientsCount) Bahan")
                        Badge(text: "\(viewModel.totalStepCount) Langkah")
                        Spacer()
                    }
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("Informasi Resep")
                    .accessibilityValue("Kurang \(viewModel.missingIngredientsCount) bahan. Membutuhkan \(viewModel.totalStepCount) langkah memasak.")
                    
                    // Pesan Kondisional
                    if viewModel.missingIngredientsCount == 0 {
                        Text("Kamu sudah punya semua yang dibutuhkan. Ayo mulai memasak!")
                            .font(.subheadline).fontWeight(.regular).foregroundColor(.black)
                            .accessibilityLabel("Status Kelengkapan Bahan")
                            .accessibilityValue("Kamu sudah punya semua yang dibutuhkan. Ayo mulai memasak!")
                    } else {
                        let missingNames = viewModel.missingDisplayableIngredients.map { $0.name }.joined(separator: ", ")
                        Text("Ups! Bahan kamu kurang: **\(missingNames)**")
                            .font(.subheadline)
                            .fontWeight(.regular)
                            .foregroundColor(.black)
                            .lineLimit(2)
                            .truncationMode(.tail)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .accessibilityLabel("Status Kelengkapan Bahan")
                            .accessibilityValue("Bahan kamu kurang: \(missingNames)")
                    }
                    
//                  Spacer()
                    
                    // Daftar Bahan
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Bahan").font(.title3).fontWeight(.bold)
                            Spacer()
                            let totalIngredients = viewModel.ownedDisplayableIngredients.count + viewModel.missingDisplayableIngredients.count
                            Text("\(totalIngredients) Item").font(.body).fontWeight(.bold).foregroundColor(.gray)
                        }
                        .accessibilityElement(children: .ignore)
                        .accessibilityAddTraits(.isHeader)

                        ForEach(viewModel.ownedDisplayableIngredients) { IngredientRowView(ingredient: $0, owned: true) }
                        ForEach(viewModel.missingDisplayableIngredients) { IngredientRowView(ingredient: $0, owned: false) }
                    }
                    
//                  Spacer()

                    // Daftar Langkah-langkah
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Langkah-langkah").font(.title3).fontWeight(.bold)
                            .accessibilityAddTraits(.isHeader)
                        ForEach(Array(viewModel.steps.enumerated()), id: \.offset) { StepRowView(index: $0 + 1, instruction: $1) }
                    }
                    
                }
                .padding(20)
                .frame(maxWidth: .infinity)
                .background(Color(.systemBackground))
                .cornerRadius(25)
                .padding(.top, 250)
            }
        }
        .ignoresSafeArea(.all, edges: .top)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("")
            }
        }
        .onAppear {
            checkIfRecipeIsSaved()
        }
    }
    
    // MARK: - Check saved state
    private func checkIfRecipeIsSaved() {
        let recipeName = viewModel.recipeName  // Capture value outside the predicate

        let descriptor = FetchDescriptor<RecipeModel>(
            predicate: #Predicate { $0.name == recipeName }
        )

        do {
            if let _ = try modelContext.fetch(descriptor).first {
                viewModel.isLiked = true
            } else {
                viewModel.isLiked = false
            }
        } catch {
            print("❌ Error checking saved recipe: \(error)")
        }
    }
}


private struct IngredientRowView: View {
    let ingredient: DisplayableIngredient
    let owned: Bool

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: owned ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.headline)
                    .foregroundColor(owned ? Color(hex: "006E6D") : .red)

                HStack {
                    Text(ingredient.name.capitalized)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(owned ? Color(hex: "006E6D") : .red)
                    
                    Spacer()
                    
                    Text(ingredient.quantity)
                        .font(.subheadline)
                        .fontWeight(.regular)
                }
            }

            DottedLine()
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(ingredient.name.capitalized), \(ingredient.quantity)")
        .accessibilityValue(owned ? "Tersedia" : "Tidak tersedia")
    }
}

private struct StepRowView: View {
    let index: Int
    let instruction: String
    
    private var cleanedInstruction: String {
        instruction
            .replacingOccurrences(of: "\\d+\\)", with: "", options: .regularExpression)
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var body: some View {
        VStack (alignment: .leading, spacing: 12) {
            HStack {
                BadgeStep(text: "Langkah \(index)")
                Spacer()
            }
            Text(cleanedInstruction)
            .font(.body)
            .fontWeight(.regular)
            .padding([.horizontal, .bottom], 16)
            .fixedSize(horizontal: false, vertical: true)
        }.background(Color.white).cornerRadius(10).overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.2), lineWidth: 1))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Langkah \(index)")
        .accessibilityValue(cleanedInstruction)
    }
}

private struct DottedLine: View {
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                path.move(to: CGPoint(x: 0, y: geometry.size.height / 2))
                path.addLine(to: CGPoint(x: geometry.size.width, y: geometry.size.height / 2))
            }.stroke(style: StrokeStyle(lineWidth: 1, dash: [3])).foregroundColor(.gray.opacity(0.4))
        }.frame(height: 1)
        .accessibilityHidden(true)
    }
}
