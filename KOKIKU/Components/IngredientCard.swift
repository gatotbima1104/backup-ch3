//
//  IngredientCard.swift
//  MyQuickCook
//
//  Created by Muhamad Gatot Supiadin on 17/06/25.
//

import SwiftUI

struct IngredientCardView: View {
    
    let ingredient: IngredientModel
    @Binding var selectedIngredients: [String]
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack (spacing: 16) {
                
                Button {
                    toggleSelection()
                } label: {
                    Image(systemName: selectedIngredients.contains(ingredient.id) ? "checkmark.square.fill" : "checkmark.square")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.white, Color(hex: "006E6D"))
                        .font(.largeTitle)
                }
                .padding(.leading, 6)
                
                VStack (spacing: -2) {
                    HStack {
                        Text(ingredient.name.firstLetterUppercased)
                            .font(.headline)
                            .fontWeight(.bold)
                        Spacer()
                        Text("Tersimpan")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    .padding(.leading, -4)
                    
                    HStack {
                        Text("\(ingredient.storage)")
                            .font(.subheadline)
                            .fontWeight(.light)
                        Spacer()
                        Text(daysStored != 0 ? "\(daysStored) Hari" : "Hari ini")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .padding(4)
                            .foregroundStyle(
                                daysStored <= 2 ? Color.blue :
                                    daysStored <= 5 ? Color.yellow :
                                    Color.red
                            )
                    }
                    .padding(.leading, -4)
                }
                
                Spacer()
            }
        }
        .padding(6)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(isSelected ? Color(hex: "006E6D").opacity(0.1) : Color.clear)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
        .overlay(
            ZStack(alignment: .topTrailing) {
                if ingredient.shouldNotify() {
//                    Text("\(ingredient.daysSinceStored()) hari")
//                        .font(.caption2)
//                        .foregroundColor(.white)
//                        .padding(.horizontal, 6)
//                        .padding(.vertical, 3)
//                        .background(Color.orange)
//                        .cornerRadius(6)
//                        .padding(8)
                } else if ingredient.daysSinceStored() > 0 {
//                    Text("\(ingredient.daysSinceStored()) hari")
//                        .font(.caption2)
//                        .foregroundColor(.white)
//                        .padding(.horizontal, 6)
//                        .padding(.vertical, 3)
//                        .background(Color.green)
//                        .cornerRadius(6)
//                        .padding(8)
                }
            }
        )
//        .onAppear {
//            if daysStored > 5 && !selectedIngredients.contains(ingredient.id) {
//                selectedIngredients.append(ingredient.id)
//            }
//        }
    }
    
    // check card selected
    private var isSelected: Bool {
        selectedIngredients.contains(ingredient.id)
    }
    
    // Check selected toggle
    private func toggleSelection() {
        if isSelected {
            selectedIngredients.removeAll { $0 == ingredient.id }
        } else {
            selectedIngredients.append(ingredient.id)
            print("✅ Selected: \(selectedIngredients)")
        }
    }
    
    // stored days count
    private var daysStored: Int {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: ingredient.date)
        let end = calendar.startOfDay(for: Date())
        let components = calendar.dateComponents([.day], from: start, to: end)
        return max(components.day ?? 0, 0)
    }
}
