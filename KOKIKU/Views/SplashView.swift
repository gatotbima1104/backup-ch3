//
//  SplashView.swift
//  MyQuickCook
//
//  Created by Muhamad Gatot Supiadin on 25/06/25.
//

import SwiftUI

struct SplashView: View {
    @State private var logoScale: CGFloat = 0.8
    @State private var textOpacity: Double = 0
    @State private var textOffset: CGFloat = 20
    @State private var textScale: CGFloat = 0.8
    @State private var viewOpacity: Double = 0

    var body: some View {
        VStack {
            LottieView(animationName: "splash_screen")
                .frame(height: 200)
                .scaleEffect(logoScale)
                .padding(.top, -59)
                .onAppear {
                    // Animate full view fade-in
                    withAnimation(.easeIn(duration: 0.5)) {
                        viewOpacity = 1
                    }

                    // Animate logo scaling
                    withAnimation(.easeOut(duration: 1.2)) {
                        logoScale = 1.1
                    }

                    // Animate text appearance
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        withAnimation(.easeOut(duration: 0.5)) {
                            textOpacity = 1
                            textOffset = 0
                            textScale = 1
                        }
                    }
                }

            Text("KOKIKU")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(Color(hex: "006E6D"))
                .opacity(textOpacity)
                .offset(y: textOffset)
                .scaleEffect(textScale)
                .padding(.top, 30)
        }
        .opacity(viewOpacity)
    }
}

#Preview {
    SplashView()
}
