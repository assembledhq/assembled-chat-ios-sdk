//
//  MainTabView.swift
//  AssembledChatExample
//
//  Main navigation for the example app
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            SwiftUIExampleView()
                .tabItem {
                    Label("SwiftUI", systemImage: "swift")
                }
            
            UIKitExampleViewWrapper()
                .tabItem {
                    Label("UIKit", systemImage: "rectangle.stack")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}

#Preview {
    MainTabView()
}

