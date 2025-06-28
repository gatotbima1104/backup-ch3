//
//  Router.swift
//  MyQuickCook
//
//  Created by Muhamad Gatot Supiadin on 22/06/25.
//

import SwiftUI

enum Route: Hashable {
    case fridge
    case inputByText
    case inputByImage
    case favoriteView
    case onBoarding
}

class Router: ObservableObject {
    @Published var path = NavigationPath()

    func navigate(to route: Route) {
        path.append(route)
    }
    
    func goBack() {
        path.removeLast()
    }
    
    func reset() {
        path = NavigationPath()
    }
    
}
