//
//  TabView.swift
//  MyQuickCook
//
//  Created by Muhamad Gatot Supiadin on 18/06/25.
//

import SwiftUI

struct CustomTabView: View {
    
    @Binding var selection: Int
    let tabs: [TabItem]
    
    
    var body: some View {
        TabView(selection: $selection) {
            ForEach(tabs, id: \.tag) { tab in
               tab.content
                   .tabItem {
                       Label(tab.title, systemImage: tab.systemImage)
                   }
                   .tag(tab.tag)
           }
        }
    }
}
