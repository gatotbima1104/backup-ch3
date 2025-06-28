//
//  FridgeEmptyView.swift
//  MyQuickCook
//
//  Created by Muhamad Gatot Supiadin on 19/06/25.
//
import SwiftUI

struct FridgeEmptyView: View {
    
    @ObservedObject var fridgeViewModel: FridgeViewModel
    
    var body: some View {
        VStack (spacing: 16) {
            
            HStack {
              Text("KOKIKU")
                .foregroundStyle(Color(hex: "006E6D"))
                .font(.title)
                .fontWeight(.bold)
                
                Spacer()
                
                Button {
                    fridgeViewModel.isNavigateToFavorite = true
                } label: {
                    Image(systemName: "heart.fill")
                        .font(.title3)
                        .padding()
                        .foregroundStyle(Color.white)
                        .background(Color(hex: "006E6D"))
                        .frame(maxWidth: 40, maxHeight: 40)
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 16)
            
            
            // Search field
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Cari bahan kamu...", text: $fridgeViewModel.searchText)
                    .textFieldStyle(.plain)
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
                .font(.title3)
                .fontWeight(.bold)
                
                Spacer()
                
                Image(systemName: "trash")
                    .font(.title3)
                    .padding()
                    .foregroundStyle(Color.white)
                    .background(Color.gray)
                    .frame(maxWidth: 40, maxHeight: 40)
                    .cornerRadius(8)
                
                // Button
                Button(action: {
                    fridgeViewModel.isPresented = true
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
            .padding(.horizontal, 8)
            .padding(.top, 16)
            .padding(.bottom, 8)
            
            Spacer ()
            
            VStack {
                Image("mascot")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                
                VStack(spacing: 32) {
                    Text("Ayo tambahkan bahan masakan kamu!")
                        .font(.title2)
                        .foregroundStyle(Color(hex: "006E6D"))
                        .multilineTextAlignment(.center)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                        .frame(maxWidth: 350)

                    // Button
                    Button(action: {
                        fridgeViewModel.isPresented = true
                    }){
                        HStack {
                            Text("Tambah")
                                .foregroundColor(.white)
                                .font(.title3)
                                .fontWeight(.bold)
                        }
                        .frame(width: 130, height: 50)
                        .background(Color(hex: "006E6D"))
                        .cornerRadius(8)
                    }
                }
            }
            .padding(.top, -48)
            
            
            Spacer ()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    FridgeEmptyView(fridgeViewModel: FridgeViewModel())
}
