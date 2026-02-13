//
//  ContentView.swift
//  Demo
//
//  Created by Tihomir Videnov on 23.11.24.
//

import SwiftUI
import FeaturePortal

struct ContentView: View {
    var body: some View {
        TabView {
            FeaturePortal.FeatureListView()
                .featurePrompt()
                .tabItem {
                    Label("Portal", systemImage: "list.bullet")
                }

            MascotPreviewScreen()
                .tabItem {
                    Label("Mascot", systemImage: "lightbulb.fill")
                }
        }
    }
}

#Preview {
    ContentView()
}
