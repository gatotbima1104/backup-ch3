//
//  OnboardingView.swift
//  MyQuickCook
//
//  Created by JACKY HUANG WIJAYA on 19/06/25.
//

import SwiftUI

struct OnboardingView: View {
    @StateObject var viewModel = OnboardingViewModel()
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false

    var body: some View {
        VStack {
            TabView(selection: $viewModel.currentIndex) {
                ForEach(viewModel.onboardingPages.indices, id: \.self) { index in
                    OnboardingPageView(
                        page: viewModel.onboardingPages[index],
                        index: index,
                        currentIndex: viewModel.currentIndex
                    )
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .onChange(of: viewModel.currentIndex) { _, newIndex in
                UIAccessibility.post(notification: .screenChanged, argument: "Halaman \(newIndex + 1), \(viewModel.onboardingPages[newIndex].title)")
            }
            .accessibilityLabel("Perkenalan Aplikasi")
            .accessibilityHint("Geser ke kiri atau kanan untuk berpindah halaman.")

            PageControl(
                numberOfPages: viewModel.onboardingPages.count,
                currentPage: viewModel.currentIndex
            )
            .padding(.bottom, 20)
            .padding(.top, 20)

            Button(action: {
                if viewModel.showNextButton {
                    viewModel.goToNextPage()
                } else if viewModel.showStartButton {
                    hasCompletedOnboarding = true
                }
            }) {
                Text(viewModel.showStartButton ? "Mulai" : "Selanjutnya")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "006E6D"))
                    .cornerRadius(10)
            }
            .accessibilityLabel(viewModel.showStartButton ? "Mulai" : "Selanjutnya")
            .accessibilityHint(viewModel.showStartButton ? "Ketuk untuk menyelesaikan perkenalan dan masuk ke aplikasi." : "Ketuk untuk melihat halaman berikutnya.")
            .padding(.horizontal)
            .padding(.bottom, 50)
        }
    }
}

struct OnboardingPageView: View {
    let page: OnboardingData
    let index: Int
    let currentIndex: Int

    @State private var xOffset: CGFloat = -UIScreen.main.bounds.width
    @State private var yOffset: CGFloat = 50
    @State private var showSecondImage = false

    var body: some View {
        // Gabungkan semua elemen di halaman ini agar VoiceOver membacanya sebagai satu kesatuan.
        VStack {
            ZStack {
                // Beri label aksesibilitas pada setiap gambar/animasi
                if index == 0 {
                    LottieView(animationName: "onboarding-1")
                        .frame(height: 300)
                        .padding(.top, 0)
                        .accessibilityLabel("Ilustrasi fitur pemindai bahan makanan menggunakan kamera.")
                } else if index == 1 {
                    VStack(spacing: 0) {
                        Image("onboarding2")
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 400)
                            .padding(.top, 50)
                            .padding(.leading, 70)
                            .accessibilityLabel("Ilustrasi berbagai resep yang bisa direkomendasikan.")
                        Spacer()
                    }
                    .ignoresSafeArea()
                } else {
                    LottieView(animationName: "onboarding-3")
                        .frame(height: 300)
                        .padding(.top, 50)
                        .accessibilityLabel("Ilustrasi kemudahan memasak dengan mengikuti langkah-langkah di aplikasi.")
                }

                // Gambar animasi tambahan ini murni dekoratif.
                // Sembunyikan dari VoiceOver untuk menghindari kebingungan.
                if index == 1 {
                    ZStack {
                        Image("easeIn1")
                            .resizable().scaledToFit().frame(width: 300)
                            .offset(x: showSecondImage ? 5 : xOffset, y: showSecondImage ? 80 : yOffset)
                            .opacity(1)

                        Image("easeIn2")
                            .resizable().scaledToFit().frame(width: 300)
                            .offset(x: xOffset, y: yOffset)
                            .opacity(showSecondImage ? 1 : 0)
                    }
                    .accessibilityHidden(true) // Sembunyikan ZStack ini
                    .onAppear {
                        // ... logika animasi
                    }
                }
            }

            // Text content
            VStack(spacing: 16) {
                Spacer()
                Text(page.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .foregroundColor(Color(hex: "006E6D"))
                    .accessibilityAddTraits(.isHeader)

                Text(page.description)
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding(.top, 300)
        }
    }
}

struct PageControl: View {
    let numberOfPages: Int
    let currentPage: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<numberOfPages, id: \.self) { index in
                Circle()
                    .fill(index == currentPage ? Color(hex: "006E6D") : Color.gray.opacity(0.5))
                    .frame(width: 10, height: 10)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Indikator halaman")
        .accessibilityValue("Halaman \(currentPage + 1) dari \(numberOfPages)")
    }
}

#Preview{
    OnboardingView()
}
