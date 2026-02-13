//
//  DemoApp.swift
//  Demo
//
//  Created by Tihomir Videnov on 23.11.24.
//

import SwiftUI
import FeaturePortal

@main
struct DemoApp: App {

  init () {
    FeaturePortal.configure(apiKey: "cmjj2poso0003r8z4cdkrkybt")
    FeaturePortal.logAppLaunch()
  }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
