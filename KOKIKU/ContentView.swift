//
//  ContentView.swift
//  KOKIKU
//
//  Created by Muhamad Gatot Supiadin on 28/06/25.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var viewModel = ContentViewModel()
    @AppStorage("hasCompletedOnboarding") private var  hasCompletedOnboarding: Bool = false // check isFirstLaunch

        var body: some View {
            if hasCompletedOnboarding {
                FridgeView()
            } else {
                OnboardingView()
            }
        }
}

#Preview {
    ContentView()
}
