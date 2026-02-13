# Feature Prompt — Engagement-Based Feature Request Prompt

The Feature Prompt is an animated, non-intrusive prompt that invites engaged users to submit feature requests. A friendly lightbulb mascot appears from the bottom of the screen, waves, and presents a call-to-action that opens the `FeatureListView`.

## How It Works

The SDK automatically tracks user engagement signals. When a user crosses all configured thresholds, the mascot appears at a natural moment (app foreground, view appear). Tapping the prompt opens the feature request screen as a sheet.

**Animation sequence:**
1. Mascot slides up from the bottom-right with a spring animation
2. Waves its arm in greeting
3. A speech bubble appears with a friendly message and CTA button
4. Gently bobs while waiting for interaction
5. Tapping the CTA opens `FeatureListView`; dismissing slides it away

## Quick Start

```swift
import FeaturePortal

@main
struct MyApp: App {
    init() {
        FeaturePortal.configure(apiKey: "your-api-key")
        FeaturePortal.logAppLaunch()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .featurePrompt()
        }
    }
}
```

Then, whenever the user does something meaningful in your app:

```swift
FeaturePortal.logSignificantEvent()
```

That's it. The SDK handles the rest — tracking, eligibility, presentation, cooldowns, and opt-out.

## Engagement Signals

The prompt requires **all** of these conditions to be met simultaneously (AND logic):

| Signal | Default | Description |
|--------|---------|-------------|
| App launches | >= 5 | User has opened the app multiple times |
| Days since install | >= 7 | User is not brand new |
| Significant events | >= 3 | User has done meaningful things (you define what's meaningful) |
| Recent sessions (14-day window) | >= 3 | User is currently active |
| Cooldown | 30 days | Minimum gap between prompts |
| Annual cap | 12 | Max prompts per rolling 365-day period |

### What counts as a "significant event"?

You decide. Call `FeaturePortal.logSignificantEvent()` when the user completes actions that indicate real engagement. Examples:

- Completed a purchase
- Finished onboarding
- Used a core feature for the first time
- Reached a milestone
- Created content

## Custom Configuration

Pass a `FeaturePromptConfiguration` to customize thresholds:

```swift
var config = FeaturePromptConfiguration(
    minAppLaunchCount: 10,          // More launches required
    minDaysSinceFirstLaunch: 14,    // Wait 2 weeks
    minSignificantEventCount: 5,    // More engagement needed
    cooldownDays: 14,               // Show every 2 weeks
    maxPromptsPerYear: 12           // Up to monthly
)

FeaturePortal.configure(apiKey: "your-api-key", promptConfiguration: config)
```

All parameters have sensible defaults — you only need to override what you want to change.

### Disabling the Prompt

Pass `nil` to disable the engagement prompt entirely:

```swift
FeaturePortal.configure(apiKey: "your-api-key", promptConfiguration: nil)
```

## Custom Messages

Customize the speech bubble text and CTA:

```swift
ContentView()
    .featurePrompt(
        message: "We'd love your input!",
        ctaText: "Suggest a Feature"
    )
```

## Manual Invocation (forceShow)

You can trigger the mascot on demand — bypassing all engagement checks — using the `forceShow` binding. This is useful for:

- A "Give Feedback" button in your settings screen
- Showing the prompt after a key user milestone
- Demo/preview purposes

```swift
struct SettingsView: View {
    @State private var showMascot = false

    var body: some View {
        Form {
            Button("Share your ideas") {
                showMascot = true
            }
        }
        .featurePrompt(forceShow: $showMascot)
    }
}
```

When `forceShow` is set to `true`, the mascot appears immediately with the full animation sequence. The binding resets to `false` automatically after triggering.

You can combine `forceShow` with custom messages:

```swift
.featurePrompt(
    message: "You just hit a milestone! Got ideas for what's next?",
    ctaText: "Suggest a Feature",
    forceShow: $showMascot
)
```

## Dismiss Interactions

Users can dismiss the mascot prompt in three ways:

- **Swipe down** on the mascot — slides it away
- **Tap the X button** on the speech bubble — dismisses the prompt
- **Tap "Don't show again"** — permanently suppresses the prompt (opt-out)

Tapping the mascot or the CTA button opens `FeatureListView` as a sheet, then the mascot dismisses.

## User Opt-Out

When a user taps "Don't show again", the prompt is permanently suppressed. You can provide a way to re-enable it from your settings:

```swift
// Re-enable prompts (e.g., from a settings toggle)
FeaturePortal.promptTrigger?.resetOptOut()

// Check current opt-out status
let isOptedOut = FeaturePortal.promptTrigger?.isOptedOut ?? false
```

## API Reference

### FeaturePortal (Static Methods)

| Method | Description |
|--------|-------------|
| `configure(apiKey:promptConfiguration:)` | Initialize the SDK. Prompt configuration is optional (defaults included). |
| `logAppLaunch()` | Log an app launch. Call once per launch in your `App.init` or `AppDelegate`. |
| `logSignificantEvent()` | Log a meaningful user action. |
| `promptTrigger` | Access the shared `FeaturePromptTrigger` instance (read-only). |

### FeaturePromptConfiguration

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `minAppLaunchCount` | `Int` | 5 | Minimum app launches |
| `minDaysSinceFirstLaunch` | `Int` | 7 | Minimum days since first launch |
| `minSignificantEventCount` | `Int` | 3 | Minimum significant events |
| `minRecentSessionCount` | `Int` | 3 | Minimum sessions in recent window |
| `recentSessionWindowDays` | `Int` | 14 | Days in "recent" session window |
| `cooldownDays` | `Int` | 30 | Minimum days between prompts |
| `maxPromptsPerYear` | `Int` | 12 | Max prompts per 365-day period |

### FeaturePromptTrigger

| Method / Property | Description |
|-------------------|-------------|
| `shouldShowPrompt() -> Bool` | Check eligibility (used internally by the modifier) |
| `recordPromptShown()` | Record that the prompt was displayed |
| `userDidOptOut()` | Permanently suppress the prompt |
| `resetOptOut()` | Re-enable after opt-out |
| `resetAllData()` | Clear all engagement data (useful for testing / logout) |
| `isOptedOut: Bool` | Whether the user opted out |
| `totalPromptsShown: Int` | Total prompts shown to date |
| `currentLaunchCount: Int` | Current app launch count |
| `currentSignificantEventCount: Int` | Current significant event count |

### View Modifier

```swift
.featurePrompt(
    message: String = "Help shape this app!",
    ctaText: String = "Share a Feature Request",
    forceShow: Binding<Bool> = .constant(false)
)
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `message` | `String` | `"Help shape this app!"` | Text shown in the speech bubble below the heading |
| `ctaText` | `String` | `"Share a Feature Request"` | Label on the call-to-action button |
| `forceShow` | `Binding<Bool>` | `.constant(false)` | Set to `true` to show the mascot immediately, bypassing eligibility. Resets to `false` after triggering. |

## Data Storage

All engagement data is stored in a dedicated `UserDefaults` suite (`com.featureportal.engagement`), keeping it isolated from your app's standard `UserDefaults`. Data is local-only and never sent to any server.

## Testing

### Using forceShow (simplest)

The easiest way to test the mascot during development — use the `forceShow` binding to trigger it on a button tap:

```swift
struct DebugView: View {
    @State private var trigger = false

    var body: some View {
        Button("Test Mascot") { trigger = true }
            .featurePrompt(forceShow: $trigger)
    }
}
```

### Resetting engagement data

Use `resetAllData()` to clear all persisted engagement state:

```swift
#if DEBUG
FeaturePortal.promptTrigger?.resetAllData()
#endif
```

### Lowering thresholds

To make the automatic prompt appear immediately, configure with minimal thresholds:

```swift
#if DEBUG
let config = FeaturePromptConfiguration(
    minAppLaunchCount: 1,
    minDaysSinceFirstLaunch: 0,
    minSignificantEventCount: 0,
    minRecentSessionCount: 1,
    cooldownDays: 0,
    maxPromptsPerYear: 999
)
FeaturePortal.configure(apiKey: "test-key", promptConfiguration: config)
FeaturePortal.logAppLaunch()
FeaturePortal.logSignificantEvent()
#endif
```
