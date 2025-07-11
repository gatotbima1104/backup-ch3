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
            .gesture(
                DragGesture()
                    .onEnded { value in
                        if value.translation.width < 0 {
                            viewModel.goToNextPage()
                        } else if value.translation.width > 0 {
                            viewModel.goToPreviousPage()
                        }
                    }
            )

            PageControl(numberOfPages: viewModel.onboardingPages.count, currentPage: viewModel.currentIndex)
                .padding(.vertical, 20)

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
        ZStack {
            if index == 0 {
                LottieView(animationName: "onboarding-1")
                    .frame(height: 300)
                    .padding(.top, 0)
            } else if index == 1 {
                VStack(spacing: 0) {
                    Image("onboarding2")
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 400)
                        .padding(.top, 50)
                        .padding(.leading, 70)
                    Spacer()
                }
                .ignoresSafeArea()
            } else {
                LottieView(animationName: "onboarding-3")
                    .frame(height: 300)
                    .padding(.top, 50)
            }

            if index == 1 {
                ZStack {
                    Image("easeIn1")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300)
                        .offset(x: showSecondImage ? 5 : xOffset, y: showSecondImage ? 80 : yOffset)
                        .opacity(1)

                    Image("easeIn2")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300)
                        .offset(x: xOffset, y: yOffset)
                        .opacity(showSecondImage ? 1 : 0)
                }
                .onAppear {
                    guard currentIndex == 1 else { return }

                    withAnimation(.easeIn(duration: 1)) {
                        xOffset = -60
                        yOffset = 50
                    }

                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        withAnimation(.easeIn(duration: 1)) {
                            showSecondImage = true
                            xOffset = 30
                            yOffset = 0
                        }
                    }
                }
            }

            VStack(spacing: 16) {
                Spacer()
                Text(page.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .foregroundColor(Color(hex: "006E6D"))

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
    }
}

#Preview {
    OnboardingView()
}
