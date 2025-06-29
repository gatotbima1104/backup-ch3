//
//  HeaderView.swift
//  MyQuickCook
//
//  Created by Muhamad Gatot Supiadin on 22/06/25.
//

import SwiftUI
import SwiftData

struct HeaderView: View {
    @Binding var searchText: String
    @Binding var isNavigateToFavorite: Bool
    @Binding var isPresented: Bool
    @Binding var showDeleteConfirmation: Bool
    @Binding var selectedIngredientIDs: [String]
    
    let deleteAction: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("KOKIKU")
                    .foregroundStyle(Color(hex: "006E6D"))
                    .font(.title)
                    .fontWeight(.bold)

                Spacer()

                Button {
                    isNavigateToFavorite = true
                } label: {
                    Image(systemName: "heart.fill")
                        .font(.title3)
                        .padding()
                        .foregroundStyle(.white)
                        .background(Color(hex: "006E6D"))
                        .frame(width: 40, height: 40)
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal, 8)

            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Cari bahan kamu...", text: $searchText)
                    .padding(8)
                    .font(.title3)
            }
            .padding(.horizontal)
            .padding(.vertical, 6)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            .padding(.horizontal, 8)

            HStack {
                Text("Pilih bahan")
                    .font(.title2)
                    .fontWeight(.bold)

                Spacer()

                Button {
                    showDeleteConfirmation = true
                } label: {
                    Image(systemName: "trash")
                        .font(.title3)
                        .padding()
                        .foregroundStyle(.white)
                        .background(selectedIngredientIDs.isEmpty ? Color.gray : Color(hex: "#AD1D00"))
                        .frame(width: 40, height: 40)
                        .cornerRadius(8)
                }
                .disabled(selectedIngredientIDs.isEmpty)

                Button {
                    isPresented = true
                } label: {
                    Image(systemName: "plus")
                        .font(.title3)
                        .fontWeight(.bold)
                        .padding()
                        .foregroundStyle(.white)
                        .background(!selectedIngredientIDs.isEmpty ? Color.gray : Color(hex: "006E6D"))
                        .frame(width: 40, height: 40)
                        .cornerRadius(8)
                }
                .disabled(!selectedIngredientIDs.isEmpty)
            }
            .padding(.horizontal, 4)
            .padding(.top, 16)
            .padding(.bottom, 8)
            .alert("Hapus Bahan", isPresented: $showDeleteConfirmation) {
                Button("Tidak", role: .cancel) {}
                Button("Ya", role: .destructive) {
                    deleteAction()
                }
            } message: {
                Text("Kamu yakin hapus bahan yang sudah dipilih?")
            }
        }
    }
}
