# FeaturePortal iOS SDK

[![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS%2017+-blue.svg)](https://developer.apple.com)
[![SPM](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://swift.org/package-manager)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

The official iOS SDK for [FeaturePortal](https://featureportal.com) - a powerful feature request and roadmap management platform. Integrate beautiful, native feature request and roadmap views directly into your iOS app.

## Features

- **Native SwiftUI Interface**: Beautiful, pre-built UI components that match iOS design guidelines
- **Feature Requests**: Allow users to submit and vote on feature requests directly from your app
- **Public Roadmap**: Keep your users informed with an integrated roadmap view
- **Real-time Updates**: Automatically sync feature requests and roadmap items
- **Easy Integration**: Simple configuration with just a few lines of code

## Requirements

- iOS 17.0+
- Swift 5.9+
- Xcode 15.0+

## Installation

### Swift Package Manager

Add FeaturePortal to your project using Swift Package Manager:

1. In Xcode, select **File → Add Package Dependencies...**
2. Enter the repository URL:
   ```
   https://github.com/FeaturePortal/featureportal-ios.git
   ```
3. Select the version rule (recommended: **Up to Next Major Version** with `1.0.0`)
4. Click **Add Package**

Alternatively, add it to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/FeaturePortal/featureportal-ios.git", from: "1.0.0")
]
```

## Getting Started

### 1. Get Your API Key

Before integrating the SDK, you'll need to get your API key from FeaturePortal:

1. Sign up or log in at [featureportal.com](https://featureportal.com)
2. Create a new project or select an existing one
3. Navigate to **Settings → API Keys**
4. Copy your API key

For detailed instructions, visit the [FeaturePortal Documentation](https://featureportal.com/docs).

### 2. Configure the SDK

Import FeaturePortal in your app's main file and configure it with your API key:

```swift
import SwiftUI
import FeaturePortal

@main
struct YourApp: App {

    init() {
        // Configure FeaturePortal with your API key
        FeaturePortal.configure(apiKey: "your-api-key-here")
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

### 3. Display the Feature Portal

Add the FeaturePortal view anywhere in your app:

```swift
import SwiftUI
import FeaturePortal

struct ContentView: View {
    var body: some View {
        FeaturePortal.FeatureListView()
    }
}
```

The `FeatureListView` includes a tabbed interface with:
- **Requests Tab**: View and submit feature requests
- **Roadmap Tab**: See what's planned, in progress, and completed

## Usage Examples

### Presenting as a Sheet

```swift
struct SettingsView: View {
    @State private var showFeaturePortal = false

    var body: some View {
        Button("Feature Requests & Roadmap") {
            showFeaturePortal = true
        }
        .sheet(isPresented: $showFeaturePortal) {
            FeaturePortal.FeatureListView()
        }
    }
}
```

### Presenting as a Navigation Destination

```swift
struct SettingsView: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink("Feature Requests") {
                    FeaturePortal.FeatureListView()
                }
            }
            .navigationTitle("Settings")
        }
    }
}
```

### Standalone Tab

```swift
struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }

            FeaturePortal.FeatureListView()
                .tabItem {
                    Label("Feature Requests", systemImage: "lightbulb")
                }
        }
    }
}
```

## Demo Project

This repository includes a demo project that showcases the SDK integration. To run the demo:

1. Clone this repository
2. Open `Demo/Demo.xcodeproj` in Xcode
3. Update the API key in `DemoApp.swift` with your own key
4. Build and run the project

The demo app demonstrates the basic integration and shows both the feature request and roadmap views in action.

## Documentation

For more information about FeaturePortal and its features, visit:

- [Official Documentation](https://featureportal.com/docs)
- [API Reference](https://featureportal.com/docs/api)
- [Feature Portal Website](https://featureportal.com)

## Platform Support

| Platform | Status | Minimum Version |
|----------|--------|----------------|
| iOS | ✅ Fully Supported | iOS 17.0+ |
| macOS | 🚧 Planned | TBD |
| visionOS | 🚧 Planned | TBD |

*Note: Currently iOS-only. macOS and visionOS support may be added in future releases.*

## Support

If you encounter any issues or have questions:

- Check the [Documentation](https://featureportal.com/docs)
- Open an issue on [GitHub](https://github.com/FeaturePortal/featureportal-ios/issues)
- Contact support at [featureportal.com](https://featureportal.com)

## License

This SDK is available under the MIT License. See the LICENSE file for more info.

---

Made with ❤️ by the FeaturePortal team
