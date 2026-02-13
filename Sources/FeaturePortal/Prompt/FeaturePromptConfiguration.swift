import Foundation

/// Configuration for engagement-based feature request prompts.
/// All engagement thresholds use AND logic — every condition must be met for a prompt to be eligible.
public struct FeaturePromptConfiguration: Sendable {
    /// Minimum app launches before showing a prompt.
    public var minAppLaunchCount: Int

    /// Minimum days since the first tracked launch.
    public var minDaysSinceFirstLaunch: Int

    /// Minimum significant events logged by the SDK consumer.
    public var minSignificantEventCount: Int

    /// Minimum sessions within the recent window period.
    public var minRecentSessionCount: Int

    /// Number of days that define the "recent" session window.
    public var recentSessionWindowDays: Int

    /// Minimum days between showing prompts (cooldown).
    public var cooldownDays: Int

    /// Maximum prompts per rolling 365-day period.
    public var maxPromptsPerYear: Int

    public init(
        minAppLaunchCount: Int = 5,
        minDaysSinceFirstLaunch: Int = 7,
        minSignificantEventCount: Int = 3,
        minRecentSessionCount: Int = 3,
        recentSessionWindowDays: Int = 14,
        cooldownDays: Int = 30,
        maxPromptsPerYear: Int = 12
    ) {
        self.minAppLaunchCount = minAppLaunchCount
        self.minDaysSinceFirstLaunch = minDaysSinceFirstLaunch
        self.minSignificantEventCount = minSignificantEventCount
        self.minRecentSessionCount = minRecentSessionCount
        self.recentSessionWindowDays = recentSessionWindowDays
        self.cooldownDays = cooldownDays
        self.maxPromptsPerYear = maxPromptsPerYear
    }
}
