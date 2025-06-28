//
//  OnboardingViewModel.swift
//  MyQuickCook
//
//  Created by JACKY HUANG WIJAYA on 19/06/25.
//

import Foundation
import Combine

class OnboardingViewModel: ObservableObject {
    @Published var currentIndex: Int = 0
    let onboardingPages: [OnboardingData]

    init() {
        self.onboardingPages = [
            OnboardingData(imageName: "onboarding1",
                           title: "Scan Bahan Masakan Lebih Cepat",
                           description: "Scan bahan-bahan masakan kamu menggunakan kamera, dan kami akan membantu mencatat"),
            OnboardingData(imageName: "onboarding2",
                           title: "Pilih Bahan yang Kamu Miliki",
                           description: "Pilih bahan yang kamu miliki untuk mendapatkan rekomendasi resep yang sesuai."),
            OnboardingData(imageName: "onboarding3",
                           title: "Dapatkan Rekomendasi!",
                           description: "Dapatkan rekomendasi masakan sesuai dengan bahan yang kamu punya!")
        ]
    }

    var showNextButton: Bool {
        currentIndex < onboardingPages.count - 1
    }

    var showStartButton: Bool {
        currentIndex == onboardingPages.count - 1
    }

    func goToNextPage() {
        if currentIndex < onboardingPages.count - 1 {
            currentIndex += 1
        }
    }

    func goToPreviousPage() {
        if currentIndex > 0 {
            currentIndex -= 1
        }
    }
}
