//
//  InputTextView.swift
//  MyQuickCook
//
//  Created by Muhamad Gatot Supiadin on 16/06/25.
//

import SwiftUI
import SwiftData

struct InputTextView: View {
    
    @StateObject var inputViewModel = InputViewModel() // Pull from inputviewmodel
    @Environment(\.modelContext) private var modelContext // Take from swift data
    @Environment(\.dismiss) private var dismiss
    private var isFromDetection: Bool = false
    private var isFromCamera: Bool = false
    @Binding var dismissToRoot: Bool
    
    // Inject init to take the value from camera input
    init(initialIngredients: [String] = [], dismissToRoot: Binding<Bool>? = nil) {
        self.isFromDetection = !initialIngredients.isEmpty
        _inputViewModel = StateObject(wrappedValue: InputViewModel(initialIngredients: initialIngredients))
        self._dismissToRoot = dismissToRoot ?? .constant(false)
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                List {
                    if inputViewModel.ingredientInputs.isEmpty {
                        VStack (alignment: .center) {
                            Image("mascot")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 150, height: 150)
                            
                            VStack(spacing: 32) {
                                Text("Kamu harus menambahkan minimal 1 bahan")
                                    .font(.title2)
                                    .foregroundStyle(Color(hex: "006E6D"))
                                    .multilineTextAlignment(.center)
                                    .fontWeight(.bold)
                                    .padding(.horizontal)
                                    .frame(maxWidth: 350)
                            }
                        }
                        .padding(.top, 150)
                        
                    } else {
                        // Loop all cards
                        ForEach(Array(inputViewModel.ingredientInputs.enumerated()), id: \.element.id) { index, ingredient in
                            if let binding = inputViewModel.binding(for: ingredient.id) {
                                IngredientInput(
                                    ingredient: binding,
                                    storages: inputViewModel.storages,
                                    index: index,
                                    onDelete: {
                                        inputViewModel.popCard(ingredient.id)
                                    },
                                    totalInput: inputViewModel.ingredientInputs.count
                                )
                                .listRowInsets(EdgeInsets())
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                                .padding(.bottom, 16)
                            }
                        }
                    }
                }
                .padding(.horizontal, -20)
                .scrollIndicators(.hidden)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                
                Spacer()
                
                // Save to swift data
                Button {
                    let manager = DataManager(context: modelContext)
                    manager.saveIngredients(from: inputViewModel.ingredientInputs)
                    dismiss()
                    if isFromDetection {
                        dismissToRoot = false // will close InputImageView
                    }
                } label: {
                    Text("Simpan")
                        .font(.title2)
                        .bold()
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(inputViewModel.isFormValid && !inputViewModel.ingredientInputs.isEmpty ? Color(hex: "006E6D") : Color.gray.opacity(0.5))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .disabled(!inputViewModel.isFormValid || inputViewModel.ingredientInputs.isEmpty)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .safeAreaPadding(.all)
            .navigationTitle("Tambah Bahan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        inputViewModel.addCard()
                    }){
                        Image(systemName: "plus")
                            .font(.title3)
                            .fontWeight(.bold)
                            .padding()
                            .foregroundStyle(Color.white)
                            .background(Color(hex: "006E6D"))
                            .frame(maxWidth: 40, maxHeight: 40)
                            .cornerRadius(8)
                    }
                }
            }
        }
    }
}

//#Preview {
//    InputTextView()
//}
