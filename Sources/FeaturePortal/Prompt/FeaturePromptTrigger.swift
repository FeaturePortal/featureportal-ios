import Foundation

/// Tracks user engagement and determines when to show the feature request prompt.
///
/// The trigger evaluates multiple engagement signals (app launches, significant events,
/// session frequency) and respects cooldown periods, annual caps, and user opt-out.
@MainActor
public final class FeaturePromptTrigger {

    // MARK: - Properties

    public var configuration: FeaturePromptConfiguration
    private let defaults: UserDefaults

    // MARK: - Persistence Keys

    private enum Keys {
        static let suiteName = "com.featureportal.engagement"
        static let firstLaunchDate = "firstLaunchDate"
        static let appLaunchCount = "appLaunchCount"
        static let significantEventCount = "significantEventCount"
        static let sessionTimestamps = "sessionTimestamps"
        static let lastPromptDate = "lastPromptDate"
        static let promptDatesThisYear = "promptDatesThisYear"
        static let totalPromptsShown = "totalPromptsShown"
        static let userOptedOut = "userOptedOut"
    }

    // MARK: - Initialization

    public init(configuration: FeaturePromptConfiguration = FeaturePromptConfiguration()) {
        self.configuration = configuration
        self.defaults = UserDefaults(suiteName: Keys.suiteName) ?? .standard
    }

    // MARK: - Event Logging

    /// Log an app launch. Call once per app launch (e.g., in your SwiftUI App's `init`).
    public func logAppLaunch() {
        if defaults.object(forKey: Keys.firstLaunchDate) == nil {
            defaults.set(Date().timeIntervalSince1970, forKey: Keys.firstLaunchDate)
        }

        let count = defaults.integer(forKey: Keys.appLaunchCount)
        defaults.set(count + 1, forKey: Keys.appLaunchCount)

        appendSessionTimestamp()
    }

    /// Log a significant event. The SDK consumer defines what "significant" means
    /// (e.g., completed a purchase, finished onboarding, used a core feature).
    public func logSignificantEvent() {
        let count = defaults.integer(forKey: Keys.significantEventCount)
        defaults.set(count + 1, forKey: Keys.significantEventCount)
    }

    // MARK: - Eligibility Check

    /// Returns `true` if all engagement thresholds are met and the prompt
    /// is not in cooldown, not opted out, and not over the annual limit.
    public func shouldShowPrompt() -> Bool {
        guard !defaults.bool(forKey: Keys.userOptedOut) else { return false }

        guard let firstLaunch = firstLaunchDate(),
              daysSince(firstLaunch) >= configuration.minDaysSinceFirstLaunch else {
            return false
        }

        guard defaults.integer(forKey: Keys.appLaunchCount)
                >= configuration.minAppLaunchCount else {
            return false
        }

        guard defaults.integer(forKey: Keys.significantEventCount)
                >= configuration.minSignificantEventCount else {
            return false
        }

        guard recentSessionCount() >= configuration.minRecentSessionCount else {
            return false
        }

        if let lastPrompt = lastPromptDate(),
           daysSince(lastPrompt) < configuration.cooldownDays {
            return false
        }

        guard promptCountInLastYear() < configuration.maxPromptsPerYear else {
            return false
        }

        return true
    }

    // MARK: - Prompt Lifecycle

    /// Call after actually presenting the prompt to the user.
    public func recordPromptShown() {
        let now = Date().timeIntervalSince1970
        defaults.set(now, forKey: Keys.lastPromptDate)

        var dates = promptDatesThisYear()
        dates.append(now)
        defaults.set(dates, forKey: Keys.promptDatesThisYear)

        let total = defaults.integer(forKey: Keys.totalPromptsShown)
        defaults.set(total + 1, forKey: Keys.totalPromptsShown)
    }

    /// Call when the user taps "Don't show again". Permanently suppresses the prompt.
    public func userDidOptOut() {
        defaults.set(true, forKey: Keys.userOptedOut)
    }

    /// Resets the opt-out flag (e.g., from a settings screen toggle).
    public func resetOptOut() {
        defaults.set(false, forKey: Keys.userOptedOut)
    }

    /// Resets all engagement data. Useful for testing or account logout.
    public func resetAllData() {
        [
            Keys.firstLaunchDate,
            Keys.appLaunchCount,
            Keys.significantEventCount,
            Keys.sessionTimestamps,
            Keys.lastPromptDate,
            Keys.promptDatesThisYear,
            Keys.totalPromptsShown,
            Keys.userOptedOut,
        ].forEach { defaults.removeObject(forKey: $0) }
    }

    // MARK: - Read-only State

    public var isOptedOut: Bool {
        defaults.bool(forKey: Keys.userOptedOut)
    }

    public var totalPromptsShown: Int {
        defaults.integer(forKey: Keys.totalPromptsShown)
    }

    public var currentLaunchCount: Int {
        defaults.integer(forKey: Keys.appLaunchCount)
    }

    public var currentSignificantEventCount: Int {
        defaults.integer(forKey: Keys.significantEventCount)
    }

    // MARK: - Private Helpers

    private func firstLaunchDate() -> Date? {
        let ti = defaults.double(forKey: Keys.firstLaunchDate)
        return ti > 0 ? Date(timeIntervalSince1970: ti) : nil
    }

    private func lastPromptDate() -> Date? {
        let ti = defaults.double(forKey: Keys.lastPromptDate)
        return ti > 0 ? Date(timeIntervalSince1970: ti) : nil
    }

    private func daysSince(_ date: Date) -> Int {
        Calendar.current.dateComponents([.day], from: date, to: Date()).day ?? 0
    }

    private func appendSessionTimestamp() {
        var timestamps = defaults.array(forKey: Keys.sessionTimestamps) as? [Double] ?? []
        timestamps.append(Date().timeIntervalSince1970)

        let cutoff = Date().addingTimeInterval(
            -Double(configuration.recentSessionWindowDays) * 86400
        ).timeIntervalSince1970
        timestamps = timestamps.filter { $0 >= cutoff }

        defaults.set(timestamps, forKey: Keys.sessionTimestamps)
    }

    private func recentSessionCount() -> Int {
        let timestamps = defaults.array(forKey: Keys.sessionTimestamps) as? [Double] ?? []
        let cutoff = Date().addingTimeInterval(
            -Double(configuration.recentSessionWindowDays) * 86400
        ).timeIntervalSince1970
        return timestamps.filter { $0 >= cutoff }.count
    }

    private func promptDatesThisYear() -> [Double] {
        let dates = defaults.array(forKey: Keys.promptDatesThisYear) as? [Double] ?? []
        let oneYearAgo = Date().addingTimeInterval(-365 * 86400).timeIntervalSince1970
        return dates.filter { $0 >= oneYearAgo }
    }

    private func promptCountInLastYear() -> Int {
        promptDatesThisYear().count
    }
}
