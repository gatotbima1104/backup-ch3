//
//  IngredientInput.swift
//  MyQuickCook
//
//  Created by Muhamad Gatot Supiadin on 17/06/25.
//

import SwiftUI

struct IngredientInput: View {
    
    @Binding var ingredient: Ingredient
    var storages: [String]
    var index: Int
    var onDelete: () -> Void
    var totalInput: Int
    
    @State private var filteredSuggestions: [String] = []
    @State private var showSuggestion: Bool = false
    
    private let allSuggestions: [String] = [
        "Ayam", "Udang", "Ikan", "Sapi", "Bakso", "Telur", "Nasi", "Mie", "Tempe", "Tahu", "Daging", "Cumi", "Kepiting",
        "Jagung", "Sawi", "Wortel", "Tomat", "Kubis", "Kentang", "Brokoli", "Buncis", "Kacang Panjang", "Timun", "Tauge",
        "Bayam", "Kangkung", "Daun Singkong", "Terong", "Pare", "Labu Siam", "Kacang Merah", "Oyong",
        "Bawang Merah", "Bawang Putih", "Bawang Bombai", "Cabai Merah", "Cabai Hijau", "Serai",
        "Lengkuas", "Jahe", "Kunyit", "Daun Salam", "Daun Jeruk", "Kemiri", "Ketumbar", "Lada", "Garam", "Gula", "Kecap", "Minyak Goreng", "Santan"
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            headerView
            inputFields
        }
        .padding()
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    private var headerView: some View {
        HStack {
            Text("Bahan \(index + 1)")
                .foregroundColor(Color(hex: "006E6D"))
                .fontWeight(.semibold)
                .accessibilityAddTraits(.isHeader)
            
            Spacer()
            Button(action: {
                onDelete()
            }) {
                Image(systemName: "trash")
                    .font(.title3)
                    .padding()
                    .foregroundStyle(Color.white)
                    .background(totalInput <= 1 ? Color.gray : Color(hex: "B81F00"))
                    .frame(maxWidth: 40, maxHeight: 40)
                    .cornerRadius(8)
            }
            .disabled(totalInput <= 1)
            .buttonStyle(.plain)
            .accessibilityLabel("Hapus bahan \(index + 1)")
            .accessibilityHint(totalInput <= 1 ? "Tidak dapat menghapus, minimal harus ada satu bahan." : "Ketuk untuk menghapus formulir bahan ini.")
        }
    }
    
    private var inputFields: some View {
        VStack {
            TextField("Masukkan nama bahan", text: $ingredient.name)
                .autocorrectionDisabled(true)
                .foregroundColor(Color(hex: "006E6D"))
                .padding(.vertical, 8)
                .overlay(
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.gray),
                    alignment: .bottom
                )
                .accessibilityLabel("Nama bahan \(index + 1)")
                .accessibilityHint("Ketik nama bahan, saran akan muncul saat Anda mengetik.")
                .onChange(of: ingredient.name) { value in
                    if value.isEmpty {
                        filteredSuggestions = []
                        showSuggestion = false
                    } else {
                        filteredSuggestions = allSuggestions.filter {
                            $0.lowercased().contains(value.lowercased())
                        }
                        showSuggestion = !filteredSuggestions.isEmpty
                    }
                }

            suggestionListView

            HStack {
                DatePicker("Tanggal tersimpan", selection: $ingredient.date, in: ...Date(), displayedComponents: .date)
                    .foregroundColor(.gray)
                    .padding(.vertical, 8)
                    .overlay(
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.gray),
                        alignment: .bottom
                    )
                    .accessibilityLabel("Tanggal bahan disimpan")
            }

            Menu {
                Picker("Tempat Penyimpanan", selection: $ingredient.storage) {
                    ForEach(storages, id: \.self) { storage in
                        Text(storage).tag(storage)
                    }
                }
            } label: {
                HStack {
                    Text(ingredient.storage.isEmpty ? "Tempat Penyimpanan" : ingredient.storage)
                        .foregroundColor(ingredient.storage.isEmpty ? .gray : Color(hex: "006E6D"))
                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 8)
                .overlay(
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.gray),
                    alignment: .bottom
                )
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Lokasi penyimpanan")
            .accessibilityValue(ingredient.storage.isEmpty ? "Belum dipilih" : ingredient.storage)
            .accessibilityHint("Ketuk untuk membuka pilihan lokasi penyimpanan.")
            .accessibilityAddTraits(.isButton)
            .padding(.top, 16)
            .padding(.bottom, 8)
        }
        .padding(.horizontal, 8)
    }

    private var suggestionListView: some View {
        Group {
            if showSuggestion {
                ScrollView {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(filteredSuggestions, id: \.self) { suggestion in
                            HStack {
                                Text(suggestion)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 8)
                                Spacer()
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                ingredient.name = suggestion
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                    filteredSuggestions = []
                                    showSuggestion = false
                                }
                            }
                            .accessibilityElement(children: .combine)
                            .accessibilityLabel(suggestion)
                            .accessibilityAddTraits(.isButton)
                            .accessibilityHint("Ketuk untuk memilih saran ini.")
                        }
                    }
                    .padding(.vertical, 4)
                }
                .frame(maxWidth: .infinity, maxHeight: 120)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(4)
                .accessibilityLabel("Kotak saran bahan")
            }
        }
    }
}
