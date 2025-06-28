//
//  Input.swift
//  MyQuickCook
//
//  Created by Muhamad Gatot Supiadin on 16/06/25.
//

import SwiftUI

struct InputOptions: View {
    
    // Props
    var onSelectText: () -> Void
    var onSelectCamera: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            
            // Title sheet
            Text("Tambah bahan pakai apa nih?")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(Color(hex: "006E6D"))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
                .foregroundStyle(Color.white)
                .padding(.bottom, 2)
            
            Text("Kamu bisa pilih ketik manual atau scan pakai kamera")
                .font(.body)
                .fontWeight(.regular)
                .foregroundStyle(Color.gray)
                .frame(maxWidth: 300)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            // Options input button
            HStack (spacing: 64) {
                
                // text option
                Button(action: {
                    onSelectText()
                }){
                    VStack(spacing: 8) {
                        Image(systemName: "keyboard.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.white)

                        Text("Teks")
                            .font(.body)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                    }
                    .frame(width: 100, height: 100)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(hex: "006E6D"))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.white.opacity(0.5), lineWidth: 1)
                    )
                }
            
                // camera option
                Button(action: {
                    onSelectCamera()
                }){
                    VStack(spacing: 8){
                        Image(systemName: "camera.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.white)
                        
                        Text("Kamera")
                            .font(.body)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.white)
                    }
                    .frame(width: 100, height: 100)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(hex: "006E6D"))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.white.opacity(0.5), lineWidth: 1)
                    )
                }
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    InputOptions(onSelectText: {}, onSelectCamera: {})
}
