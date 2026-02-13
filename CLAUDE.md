# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands

```bash
# Build the SDK
swift build

# Build for release
swift build -c release

# Run tests (uses Swift Testing framework, not XCTest)
swift test

# Demo app - open in Xcode
open Demo/Demo.xcodeproj
```

## Architecture

This is **FeaturePortal iOS SDK** - a SwiftUI-based feature request portal that integrates with featureportal.com.

**Core Components:**
- `FeaturePortal` - Static entry point, call `FeaturePortal.configure(apiKey:)` before use
- `FeatureListView` - Main SwiftUI view containing TabView with Requests and Roadmap tabs
- `FeaturePortalModel` - `@Observable` view model marked `@MainActor` for UI state
- `APIClient` - `actor` for thread-safe async networking
- `FeaturePromptTrigger` - `@MainActor` class tracking engagement metrics for the prompt system
- `FeaturePromptModifier` - SwiftUI `ViewModifier` that orchestrates the mascot animation and prompt overlay

**Data Flow:**
1. Configure SDK with API key → 2. Present `FeatureListView` → 3. Model fetches via `APIClient` → 4. Views bind to observable properties

**Engagement Prompt Flow:**
1. `FeaturePortal.configure()` creates `FeaturePromptTrigger` → 2. `.featurePrompt()` modifier checks eligibility on appear/foreground → 3. Mascot animates in → 4. User taps CTA → 5. `FeatureListView` opens as sheet

**Networking Pattern:**
- All network calls are async/await
- `APIClient` is an `actor` ensuring thread safety
- `APIClientProtocol` enables `MockAPIClient` for testing
- Base URL: `https://featureportal.com/api/sdk`
- Headers: `X-API-KEY`, `X-APP-USER-ID`

## Key Conventions

**Design System:**
- 4pt grid: Use `CGFloat.grid(n)` which returns `n * 4`
- Theme colors: `Color.featurePortalPrimary`, `.featurePortalBlue`, `.featurePortalSecondary`, etc.
- Shadows: `featurePortalCardShadow()`, `featurePortalButtonShadow()` modifiers

**Concurrency:**
- Use `@MainActor` for all UI-related code
- Keep `APIClient` as an `actor`
- All networking must be async/await

**Engagement Prompt:**
- Engagement state stored in `UserDefaults(suiteName: "com.featureportal.engagement")`
- `FeaturePromptConfiguration` holds all thresholds (customizable)
- Mascot built with pure SwiftUI shapes (`LightbulbShape`, `SmileShape`)
- Animations use iOS 17+ APIs: `KeyframeAnimator`, `PhaseAnimator`, `.spring(duration:bounce:)`

**Testing:**
- Pass `useMockData: true` to `FeaturePortalModel` for testing
- `MockAPIClient` provides 5 sample feature requests
- Use `FeaturePromptTrigger.resetAllData()` to clear engagement state during development

## Platform Requirements

- iOS 17.0+ only
- Swift 5.9+
- Xcode 15.0+
- No external dependencies
